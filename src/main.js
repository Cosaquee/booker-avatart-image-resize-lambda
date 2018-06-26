const AWS = require('aws-sdk');

const S3 = new AWS.S3({signatureVersion: 'v4', region: 'eu-central-1'});
const Sharp = require('sharp');


const BUCKET = process.env.BUCKET;
const URL = process.env.URL;

exports.handler = function(event, context) {
    console.log(BUCKET);
    console.log(URL);
};
