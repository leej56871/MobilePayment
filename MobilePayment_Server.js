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

app.listen(port, "127.0.0.1", () => {
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
        type: Array,
        default: [],
    },
    'favContact': {
        type: Array,
        default: [],
    },
    'transferHistory': {
        type: Array,
        default: [],
    },
    'follows': {
        type: Array,
        default: [],
    },
    'friendSend': {
        type: Array,
        default: [],
    },
    'friendReceive': {
        type: Array,
        default: [],
    },
    'invitationList': {
        type: Array,
        default: [],
    },
});

const usersModel = mongoose.model('Users', usersSchema)

app.get('/newUser/:name/:userID/:userPassword', async (req, res) => {
    const { name, userID, userPassword } = req.params;
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
            invitationList: [],
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
        if (id === "all") {
            const result = await usersModel.find();
            console.log(result);
            res.send(result);
        }
        else {
            const result = await usersModel.findById(id);
            res.send(result);
        }
    } catch (err) {
        res.end("User info retrieve failed!");
        res.send("nil");
    }
});

app.post('/updateUserInfo/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await usersModel.findByIdAndUpdate(id, req.body, {
            new: true,
            runValidators: true,
        });
    } catch (err) {
        res.end(err);
    }
});

app.get('/friend/:action/:myID/:friendID', async (req, res) => {
    const { action, name, myID, friendID } = req.params
    console.log(req.params);
    if (action === "send") {
        try {
            const result = await usersModel.find({
                'userID': friendID,
            });
            const newFriendReceive = result;
            console.log(result);
            res.send(result);
        } catch (err) {
            console.log("Friend Process Failed!");
            console.log(err);
        }
    } else if (action === "search") {
        try {
            const result = await usersModel.find({
                'userID': { '$regex': friendID, '$options': 'i' },
            });
            // console.log(result);
            // const userList = []
            // userList.push(result)
            res.send(result);
        } catch (err) {
            console.log(err);
            res.send("Error on Friend Process!");
        }
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
        res.writeHead(404, {
            "error_type": "no_user_found"
        });
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
        const id = result[0].id;
        res.send(result[0].id);
    } catch (err) {
        res.send("No such user in Database!");
    }
});

// DELETE ALL TEST STRIPE USERS

app.get('/deleteAll', async (req, res) => {
    try {
        const cus = await stripe.customers.list();
        var array = cus.data.map(c => c.id);
        console.log(array);
        array.forEach(function (id) {
            const del = stripe.customers.del(id);
        });
    } catch (err) {
        console.log("Delete All Stripe Users Failed!");
        console.log(err);
    }
});