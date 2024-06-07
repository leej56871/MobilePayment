const { default: Stripe } = require('stripe');
const fs = require('fs');
const Secret_Key = fs.readFileSync('Secret_Key.txt', { encoding: 'utf8', flag: 'r' });
const Publishable_Key = fs.readFileSync('Publishable_Key.txt', { encoding: 'utf8', flag: 'r' });
// const Secret_Key = fs.readFileSync('Secret_Key_Live.txt', { encoding: 'utf8', flag: 'r' });
// const Publishable_Key = fs.readFileSync('Publishable_Key_Live.txt', { encoding: 'utf8', flag: 'r' });
const stripe = require('stripe')(Secret_Key);
const express = require('express');
const url = require('url');
const path = require('path');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const helmet = require('helmet');
const bcrypt = require('bcrypt');
const app = express();
app.use(helmet());
app.use(bodyParser.json());

dotenv.config({ path: './config.env' });

const port = process.env.PORT;

const server = app.listen(port, "127.0.0.1", () => {
    console.log('Listening');
});

const DB = process.env.DATABASE.replace('<PASSWORD>', process.env.DATABASE_PASSWORD);

mongoose.connect(DB, {
}).then(con => {
    console.log('DB connected!');
}).catch((err) => {
});

const usersSchema = new mongoose.Schema({
    'name': {
        type: String,
        required: [true, 'must have a name'],
    },
    'userID': {
        type: String,
        required: true,
        unique: true,
    },
    'userPassword': {
        type: String,
        required: true,
    },
    'stripeID': {
        type: String,
        required: true,
        unique: true,
    },
    'balance': {
        type: Number,
        required: [true, 0],
    },
    'contact': {
        type: [String],
        default: [],
    },
    'favContact': {
        type: [String],
        default: [],
    },
    'transferHistory': {
        type: [String],
        default: [],
    },
    'follows': {
        type: [String],
        default: [],
    },
    'friendSend': {
        type: [String],
        default: [],
    },
    'friendReceive': {
        type: [String],
        default: [],
    },
    'invitationWaiting': {
        type: [String],
        default: [],
    },
    'itemList': {
        type: [String],
        default: [],
    },
    'isMerchant': {
        type: Boolean,
    },
    'salt': {
        type: String,
        required: true,
    }
});

const usersModel = mongoose.model('Users', usersSchema)

const ws = require('ws');
const { constrainedMemory } = require('process');
const wss = new ws.WebSocket.Server({ server });
socketClient = [];
socketDict = [];
wss.on('connection', (socket) => {
    socket.on('message', (message) => {
        if (message.toString().split(':')[0].includes('id')) {
            var id = message.toString().split(':')[1];
            socket.id = id;
            if (!(socketClient.includes(socket.id))) {
                socketClient.push(socket.id);
                socketDict[socket.id] = socket;
            }
        } else if (message.toString().split(':')[0].includes('logout')) {
            socketClient = socketClient.filter((element) => element !== socket.id);
            delete socketDict[socket.id];
        } else if (message.toString().split(':')[0].includes('invite')) {
            var invitorID = message.toString().split(':')[1];
            var invitorName = message.toString().split(':')[2];
            var targetID = message.toString().split(':')[3];
            var invitationListString = message.toString().split(':')[4];
            var amount = message.toString().split(':')[5];
            var isDutch = message.toString().split(':')[6];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('inRoom')) {
            var invitorID = message.toString().split(':')[1];
            if (socketClient.includes(invitorID)) {
                socketDict[invitorID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('firstJoin')) {
            var targetID = message.toString().split(':')[2];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('outRoom')) {
            var targetID = message.toString().split(':')[2];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('deleteRoom')) {
            var targetID = message.toString().split(':')[2]
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('ready')) {
            var targetID = message.toString().split(':')[2];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('lock')) {
            var targetID = message.toString().split(':')[2];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('done')) {
            var targetID = message.toString().split(':')[2];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('paymentFinished')) {
            var invitorID = message.toString().split(':')[1];
            var targetID = message.toString().split(':')[2];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('qrScannedByMerchant')) {
            var invitorID = message.toString().split(':')[1];
            if (socketClient.includes(invitorID)) {
                socketDict[invitorID].send(message.toString());
            }
        }
    });
    socket.on('close', () => {
        socketClient = socketClient.filter((element) => element !== socket.id);
        delete socketDict[socket.id];
    });
});

app.post('/newUser', async (req, res) => {
    const { name, userID, userPassword, isMerchant } = req.body;
    try {
        const salt = bcrypt.genSaltSync(10);
        const hash = bcrypt.hashSync(userPassword, salt);
        const findSamePassword = await usersModel.exists({
            salt: salt,
            userPassword: hash,
        });

        while (findSamePassword) {
            salt = bcrypt.genSaltSync(10);
            newHash = bcrypt.hashSync(userPassword, salt);
            findSamePassword = bcrypt.compareSync(hash, newHash);
        }

        const cus = await stripe.customers.create({
            "name": name,
        });

        const newUser = await usersModel.create({
            name: name,
            userID: userID,
            userPassword: hash,
            stripeID: cus.id,
            balance: 0,
            contact: [],
            favContact: [],
            transferHistory: [],
            follows: [],
            friendSend: [],
            friendReceive: [],
            invitationWaiting: [],
            itemList: [],
            isMerchant: isMerchant,
            salt: salt,
        });

        newUser.save().then(doc => {
            res.send(doc);
        }).catch(err => {
        });
    } catch (err) {
        res.send({ 'error': 'error' });
    }
});

app.post('/getUserInfo', async (req, res) => {
    const { id } = req.body;
    try {
        if (id === "#all#") {
            const result = await usersModel.find();
            res.send(result);
        }
        else {
            const result = await usersModel.findOne({
                'userID': id
            });
            res.send(result);
        }
    } catch (err) {
        res.send("nil");
        res.end("User info retrieve failed!");
    }
});

app.post('/updateUserInfo/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await usersModel.findOneAndUpdate({
            'userID': id,
        }, req.body, {
            new: true,
            runValidators: true,
        });
    } catch (err) {
        res.end(err);
    }
});

app.post('/updateTransfer', async (req, res) => {
    const { userID, friendID, amount, date } = req.body;
    try {
        var result = await usersModel.findOne({
            'userID': userID,
        });
        let userBalance = Number(result.balance) - Number(amount);
        result = await usersModel.findOneAndUpdate({
            'userID': userID
        }, {
            $push: {
                'transferHistory': amount + '#send#' + friendID + "#" + date
            },
            'balance': userBalance,
        }, {
            new: true
        });
        var friendResult = await usersModel.findOne({
            'userID': friendID,
        });
        let friendBalance = Number(friendResult.balance) + Number(amount);
        friendResult = await usersModel.findOneAndUpdate({
            'userID': friendID
        }, {
            $push: {
                'transferHistory': amount + "#receive#" + userID + "#" + date
            },
            'balance': friendBalance,
        }, {
            new: true
        });
        res.send(result);
    } catch (err) {
        res.send(err);
    }
});

app.post('/dutchSplit/:action/:merchantID', async (req, res) => {
    const { action, merchantID } = req.params;
    const { message } = req.body;

    if (action === 'gotInvite') {
        var targetID = message.toString().split(':')[3];
        var slice0 = message.toString().split(':')[0];
        var slice1 = message.toString().split(':')[1];
        var slice2 = message.toString().split(':')[2];
        var slice3 = message.toString().split(':')[5];
        var slice4 = message.toString().split(':')[6];
        var slice5 = message.toString().split(':')[7];
        var invitationMessage = slice0 + ':' + slice1 + ':' + slice2 + ':' + slice3 + ':' + slice4 + ':' + slice5;
        try {
            var friendResult = await usersModel.findOneAndUpdate({
                'userID': targetID,
            }, {
                $push: { 'invitationWaiting': invitationMessage },
            });
            res.send(friendResult);
        } catch (err) {
        }
    } else if (action === 'deleteRoom') {
        var invitorID = message.toString().split(':')[1];
        var targetID = message.toString().split(':')[2];
        var temp = message.toString().split(':')[0] + ':' + invitorID + ':' + targetID + ':'
        var inviteMessage = message.toString().split(temp)[1];

        try {
            var invitorResult = await usersModel.findOneAndUpdate({
                'userID': invitorID,
            }, {
                $pull: { 'invitationWaiting': inviteMessage.toString() }
            }, {
                new: true,
            });
            var result = await usersModel.findOneAndUpdate({
                'userID': targetID,
            }, {
                $pull: { 'invitationWaiting': inviteMessage.toString() }
            }, {
                new: true,
            });
            res.send(result);
        } catch (err) {
        }
    } else if (action == 'payment') {
        var invitorID = message.toString().split('#')[0];
        var date = message.toString().split('#')[2];
        var receiptList = message.toString().split('#')[1]
        receiptList = receiptList.split(',');
        var totalPrice = 0;
        try {
            for (let i = 0; i < receiptList.length; i++) {
                var name = receiptList[i].split('+')[0];
                var temp = receiptList[i].split('+')[1];
                var tempList = temp.split('-');
                var id = tempList[0];
                var price = tempList[1];
                totalPrice = totalPrice + Number(price);

                var result = await usersModel.findOne({
                    'userID': id,
                    'isMerchant': false,
                });
                let userBalance = Number(result.balance) - Number(price);
                var result = await usersModel.findOneAndUpdate({
                    'userID': id,
                    'isMerchant': false,
                }, {
                    $push: {
                        'transferHistory': price + '#dutchSplit#' + merchantID + '#' + date + '#' + message.toString(),
                    },
                    'balance': userBalance,
                }, {
                    new: true
                });
            }
            var merchantResult = await usersModel.findOne({
                'userID': merchantID,
                'isMerchant': true,
            });
            let merchantBalance = Number(merchantResult.balance) + Number(totalPrice);
            var merchantResult = await usersModel.findOneAndUpdate({
                'userID': merchantID,
                'isMerchant': true,
            }, {
                $push: {
                    'transferHistory': String(totalPrice) + '#dutchSplit#' + invitorID + '#' + date + '#' + message.toString(),
                },
                'balance': merchantBalance,
            }, {
                new: true
            });
            res.send("true");
        } catch (err) {
        }
    }
});

app.post('/merchant/:action/:name/:myID/:merchantID/:amount/:date', async (req, res) => {
    const { action, name, myID, merchantID, amount, date } = req.params;
    const { item } = req.body;
    try {
        if (action == "searchOne") {
            var result = await usersModel.findOne({
                'userID': merchantID,
                'isMerchant': true,
            });
            res.send(result);
        } else if (action == "search") {
            var result = await usersModel.find({
                'userID': { '$regex': merchantID, '$options': 'i', '$ne': myID },
            });
            res.send(result);
        } else if (action == "payment") {
            var merchantResult = await usersModel.findOne({
                'userID': merchantID,
                'isMerchant': true,
            });
            let merchantBalance = Number(merchantResult.balance) + Number(amount);
            var merchantResult = await usersModel.findOneAndUpdate({
                'userID': merchantID,
                'isMerchant': true,
            }, {
                $push: {
                    'transferHistory': amount + '#payment#' + myID + '#' + date + '#' + item,
                },
                'balance': merchantBalance,
            }, {
                new: true
            });
            var result = await usersModel.findOne({
                'userID': myID,
                'isMerchant': false,
            });
            let userBalance = Number(result.balance) - Number(amount);
            var result = await usersModel.findOneAndUpdate({
                'userID': myID,
                'isMerchant': false,
            }, {
                $push: {
                    'transferHistory': amount + '#payment#' + merchantID + '#' + date + '#' + item,
                },
                'balance': userBalance,
            }, {
                new: true
            });
            res.send(result);
        }
    } catch (err) {
    }
});

app.post('/friend', async (req, res) => {
    const { action, name, myID, friendID } = req.body;
    var result = undefined;
    var friendResult = undefined;
    try {
        if (action === "send") {
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID },
                { $push: { 'friendReceive': myID + '#' + name } }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID },
                { $push: { 'friendSend': friendID + '#' + friendResult.name } }, { new: true });

        } else if (action === "search") {
            result = await usersModel.find({
                'userID': { '$regex': friendID, '$options': 'i', '$ne': myID },
                'isMerchant': false,
            });

        } else if (action === "searchOne") {
            result = await usersModel.find({
                'userID': friendID,
                'isMerchant': false,
            });

        } else if (action === "searchOneFromQRCode") {
            result = await usersModel.find({
                'userID': friendID
            });
        }

        else if (action === "cancelSend") {
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $pull: { 'friendReceive': myID + '#' + name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'friendSend': friendID + '#' + friendResult.name }
            }, { new: true });

        } else if (action === "accept") {
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $pull: { 'friendSend': myID + '#' + name }
            }, { new: true });
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $push: { 'contact': myID + '#' + name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'friendReceive': friendID + '#' + friendResult.name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $push: { 'contact': friendID + '#' + friendResult.name }
            }, { new: true });

        } else if (action === "decline") {
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $pull: { 'friendSend': myID + '#' + name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'friendReceive': friendID + '#' + friendResult.name }
            }, { new: true });

        } else if (action === "delete") {
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $pull: { 'contact': myID + '#' + name }
            }, { new: true });
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $pull: { 'favContact': myID + '#' + name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'contact': friendID + '#' + friendResult.name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'favContact': friendID + '#' + friendResult.name }
            }, { new: true });

        } else if (action === "deleteFav") {
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $pull: { 'favContact': myID + '#' + name }
            }, { new: true });
            friendResult = await usersModel.findOneAndUpdate({ 'userID': friendID }, {
                $pull: { 'contact': myID + '#' + name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'favContact': friendID + '#' + friendResult.name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'contact': friendID + '#' + friendResult.name }
            }, { new: true });

        } else if (action === "doFav") {
            friendResult = await usersModel.findOne({ 'userID': friendID });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'contact': friendID + '#' + friendResult.name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $push: { 'favContact': friendID + '#' + friendResult.name }
            }, { new: true });

        } else if (action === "undoFav") {
            friendResult = await usersModel.findOne({ 'userID': friendID });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $pull: { 'favContact': friendID + '#' + friendResult.name }
            }, { new: true });
            result = await usersModel.findOneAndUpdate({ 'userID': myID }, {
                $push: { 'contact': friendID + '#' + friendResult.name }
            }, { new: true });
        }
        res.send(result);
    } catch (err) {
    }
});

app.post('/getOnlineFriendList', async (req, res) => {
    const { userID } = req.body;
    try {
        var onlineList = []
        const result = await usersModel.findOne({ 'userID': userID });
        var friendList = result.contact;
        for (let i = 0; i < friendList.length; i++) {
            if (socketClient.includes(friendList[i].split('#')[0])) {
                onlineList.push(friendList[i].split('#')[0]);
            }
        }
        res.send(onlineList);
    } catch (err) {
        res.send("Get Online Friend List Failed!");
    }
});

app.get('/stripeCreateUser/:name', async (req, res) => {
    const { name } = req.params;
    try {
        const cus = await stripe.customers.create({
            "name": name,
        });
        res.send(cus);
    } catch (err) {
    }
});

app.post('/stripeUserID', async (req, res) => {
    const { id } = req.body;
    try {
        const cus = await stripe.customers.retrieve(id,);
        res.send(cus);
    } catch (err) {
        res.end(err);
    }
});

app.get('/stripeDeleteUser/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const cus = await stripe.customers.del(id);
        res.send(cus);
    } catch (err) {
        res.end(err);
    }
});

app.post('/stripePaymentRequest', async (req, res) => {
    const { id, paymentMethodType, currency, amount } = req.body;
    try {
        const intent = await stripe.paymentIntents.create({
            customer: id,
            amount: amount,
            currency: currency,
            automatic_payment_methods: {
                enabled: true,
                allow_redirects: 'never',
            }
        });
        res.send(intent);
    } catch (err) {
    }
});

app.get('/stripePublishableKey', async (req, res) => {
    const json = {
        "Publishable Key": Publishable_Key
    }
    res.send(json);
});

app.post('/stripeCancelPaymentIntent', async (req, res) => {
    try {
        const intent = await stripe.paymentIntents.cancel(id);
    } catch (err) {
    }
});

app.post('/authenticationProcess', async (req, res) => {
    const { userID, userPassword } = req.body;
    try {
        if (socketClient.includes(userID)) {
            res.send('-userAlreadyLoggedIn-');
        } else {
            const findUser = await usersModel.findOne({ userID: userID });
            if (findUser === undefined) {
                throw new Error('No user in DB');
            } else {
                const salt = findUser.salt;
                const input = bcrypt.hashSync(userPassword, salt);
                const result = await usersModel.findOne({ userID: userID, userPassword: input });

                if (input === result.userPassword) {
                    const id = result.userID;
                    res.send(result.userID);
                } else {
                    throw new Error('No user in DB');
                }
            }
        }
    } catch (err) {
        res.send('No such user in Database!');
    }
});

// DELETE ALL TEST STRIPE USERS

app.get('/deleteAll', async (req, res) => {
    try {
        const cus = await stripe.customers.list();
        var array = cus.data.map(c => c.id);
        array.forEach(function (id) {
            const del = stripe.customers.del(id);
        });
    } catch (err) {
    }
});