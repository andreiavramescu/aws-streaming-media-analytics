'use strict';
/**
 * This shows how to use standard Apollo client on Node.js
 */
/**
 * This shows how to use standard Apollo client on Node.js
 */

require('es6-promise').polyfill();
require('isomorphic-fetch');
const URL = require('url');
const AWS = require('aws-sdk');

const GRAPHQL_ENDPOINT = process.env.GRAPHQL_ENDPOINT;

console.log('Loading function');
exports.handler = (event, context, callback) => {
    let success = 0;
    let failure = 0;
    console.log("Event :%j", event);

    const output = event.Records.map((record) => {

        console.log("record :%j", record);
        const jsonData = JSON.parse(record.Sns.Message);
        console.log("json data :%j", jsonData);


        let mutationData = { id: "recent", count: jsonData.USER_COUNT };

        let data = {
            "variables": mutationData,
            "query": "mutation AddActiveUser($id: ID!, $count: Int!) { addActiveUser(id: $id, count: $count) { id count } }"
        };

        console.log("data :%j", data);
        // console.log("API Key :%s", API_KEY);

        // fetch(GRAPHQL_ENDPOINT, {
        //         method: 'POST',
        //         headers: { "Content-Type": "application/graphql", "X-Api-Key": API_KEY },
        //         body: JSON.stringify(data),
        //     })
        //     .then(res => res.json())
        //     .then(res => {
        //       console.log("data :%j",res);
        //     });

        const uri = URL.parse(GRAPHQL_ENDPOINT);
        console.log(uri.href);
        console.log("Region ",process.env.AWS_REGION);
        const httpRequest = new AWS.HttpRequest(uri.href, process.env.AWS_REGION);
        httpRequest.headers.host = uri.host;
        httpRequest.headers['Content-Type'] = 'application/json';
        httpRequest.method = 'POST';
        httpRequest.body = JSON.stringify(data);

        AWS.config.credentials.get(err => {
            const signer = new AWS.Signers.V4(httpRequest, "appsync", true);
            signer.addAuthorization(AWS.config.credentials, AWS.util.date.getDate());

            const options = {
                method: httpRequest.method,
                body: httpRequest.body,
                headers: httpRequest.headers
            };

            fetch(uri.href, options)
                .then(res => res.json())
                .then(json => {
                    console.log(`JSON Response = ${JSON.stringify(json, null, 2)}`);
                    callback(null, event);
                })
                .catch(err => {
                    console.error(`FETCH ERROR: ${JSON.stringify(err, null, 2)}`);
                    callback(err);
                });
        });

        return {
            recordId: record.recordId,
            result: 'Ok',
        };
    });

    callback(null, {
        records: output,
    });
};
