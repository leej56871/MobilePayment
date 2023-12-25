const { default: Stripe } = require('stripe');
const fs = require('fs');
const Secret_Key = fs.readFileSync('Secret_Key.txt', { encoding: 'utf8', flag: 'r' });
const Publishable_Key = fs.readFileSync('Publishable_Key.txt', { encoding: 'utf8', flag: 'r' });
const stripe = require('stripe')(Secret_Key);
const express = require('express');
const url = require('url');
const path = require('path');
const bodyParser = require('body-parser')

const app = express();
app.use(bodyParser.json());
const port = 3000;

// app.get((req, res) => {
//     const { query, pathname } = url.parse(req.url, true);

//     if (pathname === '/') {

//     }
// });

app.get('/', (req, res) => {
    console.log("main");
    res.send("main");
});

app.get('/userID/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const cus = await stripe.customers.retrieve(id,);
        res.send(cus);
    } catch (e) {
        res.writeHead(404, {
            "error_type": "no_user_found"
        });
        res.end("No user found!");
    }
});

app.post('/paymentRequest', async (req, res) => {
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

app.get('/getPublishableKey', async (req, res) => {
    const json = {
        "Publishable Key": Publishable_Key
    }
    res.send(json);
});

app.post('/cancelPaymentIntent', async (req, res) => {
    const { id } = req.body;
    console.log(id);
    console.log("CANCEL")
    try {
        const intent = await stripe.paymentIntents.cancel(id);
    } catch (e) {
        console.log(e);
        console.log("Cancelling Payment Intent Failed!")
    }

});


// Authentication
// const stripe = require('stripe')('sk_test_51ODjEVIazPXzDUL1L8PxMTYvSU5cvZOWQA9tBNZNXxmsVVuDpWOe3VJAzVkPt5ZSJciZ8csjxPK1W3iSfljFxPbY00vQCinSUi');
// (async () => {
//     // 아래처럼 여러가지 사업을 하는 경우 개별적인 api key를 세팅해서 per request 하는 것도 가능
//     // const stripe = require('stripe')
//     // const customers = await stripe.customers.retreieve("customer ID 여기에 쓰기", {
//     //    api_key: 'sk_test_51ODjEVIazPXzDUL1L8PxMTYvSU5cvZOWQA9tBNZNXxmsVVuDpWOe3VJAzVkPt5ZSJciZ8csjxPK1W3iSfljFxPbY00vQCinSUi'
//     //});

//     // 이 경우는 connect id를 쓰는 경우라는데 맨처음에 유저가 로그인하거나 가입할 때 connect 시켜서 할 수 있게하는 것도 가능할듯?
//     // const stripe = require('stripe')('sk_test_51ODjEVIazPXzDUL1L8PxMTYvSU5cvZOWQA9tBNZNXxmsVVuDpWOe3VJAzVkPt5ZSJciZ8csjxPK1W3iSfljFxPbY00vQCinSUi')
//     // const customer = await stripe.customers.retrieve('특정 아이디/리스트에서 확인', {
//     // stripeAccount: '이거는 내 account?인지는 잘 모르겠음 확인해야할듯'
//     // });

//     const customers = await stripe.customers.list();

//     console.log(customers);
// })();

(async () => {
    // // Create a customer with no params
    // const customer = await stripe.customers.create();
    // console.log(customer);
    // const customers = await stripe.customers.list();
    // console.log(customers);

    // // Fetch a customer
    // const cus = await stripe.customers.retrieve('cus_P2tPTer5We3euh',);
    // console.log(cus);

    // Create a customer with scalar values
    // const cus = await stripe.customers.create({
    //     email: 'joohwan-lee@example.com',
    //     name: 'JooHwan Lee',
    // })
    // console.log(cus)

    // try {
    //     const cus = await stripe.customers.create({
    //         tax_exempt: 'invalid'
    //     });
    // } catch (e) {
    //     console.log(e);
    // }
    // // const cus = await stripe.customers.create({
    // //     tax_exempt: 'reverse'
    // // });
    // // console.log(cus.tax_exempt);

    // create a customer with nested object
    // const cus = await stripe.customers.create({
    //     payment_method: 'pm_card_visa',
    //     invoice_settings: {
    //         default_payment_method: 'pm_card_visa',
    //     }
    // });
    // console.log(cus);

    // const cus = await stripe.customers.create({
    //     preferred_locales: ['en', 'es']
    // });

    // const cus = await stripe.customers.update(
    //     'customer_id', {
    //         email: 'jh@example.com'
    //     }
    // );
    // console.log(cus.email);

    // 모든 유저들 retrieve해서 아이디만 보여주기
    // const customers = await stripe.customers.list();
    // console.log(customers);
    // console.log(customers.data.map(c => c.id));

    // customers.data.map(c => c.id) 해서 얻은 아이디는 고유번호이지만 이메일은 그렇지 않음
    // 이 경우는 리스트 안에 query로 이메일을 보내서 유저들을 받는거 (필터링)
    // const customers = await stripe.customers.list({
    //     email: "joohwan-lee@example.com"
    // });

    // Delete
    // const cus = await stripe.customers.del(
    //     'id'
    // );
    // console.log(cus);

    // Custom Methods
    // First, Create a Payment Intent to Confirm
    // const intent = await stripe.paymentIntents.create({
    //     amount: 1000,
    //     currency: 'hkd'
    // });
    // console.log(intent.id);
    // console.log(intent.status);

    // Second, Confirm the Payment Intent (where we use the custom method)
    // const intent = await stripe.paymentIntents.confirm(
    //     'id of payment intent', {
    //     payment_method: 'pm_card_visa',
    // }
    // );
    // console.log(intent.id);
    // console.log(intent.status);

    // Invoice
    // const lines = await stripe.invoices.listLineItems(                   
    //     'in_ invoice id', {
    //         limit: 5
    //     }
    // );
    // console.log(lines);


})();

app.listen(port, "127.0.0.1", () => {
    console.log("Listening...");
})