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

const port = process.env.PORT;

dotenv.config({ path: './config.env' });

const DB = process.env.DATABASE.replace('<PASSWORD>', process.env.DATABASE_PASSWORD);

mongoose.connect(DB, {

}).then(con => {
    console.log('DB Connection Successful!');
}).catch((err) => {
    console.log('DB Connection Failed!');
});

const usersSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'must have a name'],
    },
    stripeId: {
        type: String,
        required: true,
        unique: true,
    },
    balance: {
        type: Number,
        required: [true, 0],
    },
    friends: {
        type: Array,
        default: [],
    },
    follows: {
        type: Array,
        default: [],
    },
});

const usersModel = mongoose.model('Users', usersSchema)

app.get('/createNewUser/:name/stripeId:', async (req, res) => {
    const { name, stripeId } = req.params;
    const newUser = await usersModel.create({
        name: name,
        stripeId: stripeId,
        balance: 0,
        friends: [],
        follows: [],
    });
    newUser.save().then(doc => {
        res.send(doc._id.toString());
    }).catch(err => {
        console.log('Error on Saving Creating New User');
    });
});

app.get('/getUserInfo/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await usersModel.findById(id);
        res.send(result);
    } catch (err) {
        res.writeHead(404, {
            status: 'failure',
            message: err,
        });
        res.end("User info retrieve failed!");
    }
});

app.post('/updateUserInfo/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await usersModel.findByIdAndUpdate(id, req.body, {
            new: true,
            runValidators: true,
        }).then(result.save());
        res.end(result);
    } catch (err) {
        res.writeHead(404, {
            "error_type": "update failed!"
        });
        res.end(err);
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

    } catch (e) {
        console.log(e);
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
    } catch (e) {
        console.log(e);
        console.log("Cancelling Payment Intent Failed!")
    }
});

app.listen(port, "127.0.0.1", () => {
    console.log("Listening...");
});