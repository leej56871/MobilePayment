const { default: Stripe } = require('stripe');
const fs = require('fs');
const Secret_Key = fs.readFileSync('Secret_Key.txt', { encoding: 'utf8', flag: 'r' });
const Publishable_Key = fs.readFileSync('Publishable_Key.txt', { encoding: 'utf8', flag: 'r' });
const stripe = require('stripe')(Secret_Key);
const express = require('express');
const url = require('url');
const path = require('path');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const app = express();
app.use(bodyParser.json());

dotenv.config({ path: './config.env' });

const port = process.env.PORT;

const server = app.listen(port, "127.0.0.1", () => {
    console.log("Listening...");
});

const DB = process.env.DATABASE.replace('<PASSWORD>', process.env.DATABASE_PASSWORD);

mongoose.connect(DB, {
}).then(con => {
    console.log('DB Connection Successful!');
}).catch((err) => {
    console.log('DB Connection Failed!');
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
});

const usersModel = mongoose.model('Users', usersSchema)

const ws = require('ws');
const wss = new ws.WebSocket.Server({ server });
socketClient = [];
socketDict = [];
wss.on('connection', (socket) => {
    console.log("New client connected!");
    socket.on('message', (message) => {
        if (message.toString().split(':')[0].includes('id')) {
            var id = message.toString().split(':')[1];
            socket.id = id;
            if (!(socketClient.includes(socket.id))) {
                socketClient.push(socket.id);
                socketDict[socket.id] = socket;
            }
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
        } else if (message.toString().split(':')[0].includes('updateRoom')) {
            var targetID = message.toString().split(":")[2];
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString().split(":")[3]);
            }
        }
        else if (message.toString().split(':')[0].includes('outRoom')) {
            var invitorID = message.toString().split(':')[1];
            if (socketClient.includes(invitorID)) {
                socketDict[invitorID].send(message.toString());
            }
        } else if (message.toString().split(':')[0].includes('deleteRoom')) {
            var targetID = message.toString().split(':')[2]
            var inviteMessage = message.toString().split(':')[3]
            if (socketClient.includes(targetID)) {
                socketDict[targetID].send(message.toString());
            }
        }
    });
    socket.on('close', () => {
        console.log("Client has disconnected!");
        socketClient = socketClient.filter((element) => element !== socket.id);
        delete socketDict[socket.id];
    });
});

app.get('/newUser/:name/:userID/:userPassword/:isMerchant', async (req, res) => {
    const { name, userID, userPassword, isMerchant } = req.params;

    try {
        const cus = await stripe.customers.create({
            "name": name,
        });
        const newUser = await usersModel.create({
            name: name,
            userID: userID,
            userPassword: userPassword,
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
        });
        newUser.save().then(doc => {
            res.send(doc);
        }).catch(err => {
            console.log('Error on Saving Creating New User');
        });
    } catch (err) {
        console.log(err);
        console.log('Creating New User Failed!');
    }
});

app.get('/getUserInfo/:id', async (req, res) => {
    const { id } = req.params;
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
        console.log(err);
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

app.get('/updateTransfer/:userID/:friendID/:amount/:date/:amount', async (req, res) => {
    const { userID, friendID, amount, date } = req.params;
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
        console.log("Error on Updating Transfer History");
        console.log(err);
        res.send(err);
    }
});

app.post('/dutchSplit/:action', async (req, res) => {
    const { action } = req.params;
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
            console.log("Adding invitation has failed!");
            console.log(err);
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
            console.log("Deleting room has failed!");
            console.log(err);
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
        console.log(err);
        res.send(err);
    }
});

app.get('/friend/:action/:name/:myID/:friendID', async (req, res) => {
    const { action, name, myID, friendID } = req.params;
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
            });

        } else if (action === "searchOne") {
            result = await usersModel.find({
                'userID': friendID
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
        console.log(err);
        res.send("Friend Process Failed!");
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
        console.log(err);
        console.log('Creating New Stripe User Failed!');
    }
});

app.get('/stripeUserID/:id', async (req, res) => {
    const { id } = req.params;
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
        console.log(err);
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
        console.log(err);
        console.log("Creating Payment Intent Failed!");
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
        console.log(err);
        console.log("Cancelling Payment Intent Failed!")
    }
});

app.get('/authenticationProcess/:userID/:userPassword', async (req, res) => {
    const { userID, userPassword } = req.params;
    try {
        const result = await usersModel.find({ userID: userID, userPassword: userPassword });
        const id = result[0].userID;
        res.send(result[0].userID);
    } catch (err) {
        res.send("No such user in Database!");
    }
});

// DELETE ALL TEST STRIPE USERS

app.get('/deleteAll', async (req, res) => {
    console.log('Delete all data in Stripe');
    try {
        const cus = await stripe.customers.list();
        var array = cus.data.map(c => c.id);
        array.forEach(function (id) {
            const del = stripe.customers.del(id);
        });
    } catch (err) {
        console.log("Delete All Stripe Users Failed!");
        console.log(err);
    }
});