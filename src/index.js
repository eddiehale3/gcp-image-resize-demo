const {Storage} = require('@google-cloud/storage');
const sharp = require('sharp');

const uploadBucketName = process.env.UPLOAD_BUCKET_NAME;
const processedBucketName = process.env.PROCESSED_BUCKET_NAME;

const client = new Storage();

/**
 * Process image and reupload to Cloud Storage 
 * @param req https://expressjs.com/en/api.html#req
 * @param res https://expressjs.com/en/api.html#res
 */
exports.imageResize = async (req, res) => {
    console.log(`request body: ${JSON.stringify(req.body)}`);

    // Get object name
    objectName = req.body.name

    // Download object    
    client.bucket(uploadBucketName).file(objectName).download((err, contents) => {
        if(err) {
            console.error(err);
        } else {
            // Resize image
            sharp(contents)
                .resize(400)
                .toBuffer()
                .then(async (data) => {
                    // Upload buffer directly to new object in GCS
                    await client.bucket(processedBucketName).file(`processed-${objectName}`).save(data);
                    res.sendStatus(200);
                })
                .catch(err => {
                    console.error(err);
                    res.sendStatus(500);
                });
        }
    });
};