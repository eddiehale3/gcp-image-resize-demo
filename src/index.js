const {Storage} = require('@google-cloud/storage');
const sharp = require('sharp');

const bucketName = process.env.BUCKET_NAME ?? 'ehale-test-bucket';
const storageBucket = new Storage().bucket(bucketName);
// const storageBucket = new Storage({
//     keyFilename: '../credentials.json'
// }).bucket(bucketName);
const re = /[^/]*$/g;

/**
 * Process image and reupload to Cloud Storage 
 * @param req https://expressjs.com/en/api.html#req
 * @param res https://expressjs.com/en/api.html#res
 */
exports.helloWorld = async (req, res) => {
    console.log(`request body: ${JSON.stringify(req.body)}`);

    // Get object name
    objectName = re.exec(req.body.protoPayload.resourceName)[0];
    console.log(`object name: ${objectName}`);

    // Download object    
    storageBucket.file(objectName).download((err, contents) => {
        if(err) {
            console.error(err);
        } else {
            // Resize image
            sharp(contents)
                .resize(400)
                .toBuffer()
                .then(async (data) => {
                    // Upload buffer directly to new object in GCS
                    await storageBucket.file(`processed/${objectName}`).save(data);
                    res.sendStatus(200);
                })
                .catch(err => {
                    console.error(err);
                    res.sendStatus(500);
                });
        }
    });
};