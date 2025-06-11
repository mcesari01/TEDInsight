const connect_to_db = require('./db');
const talk = require('./Talk');

module.exports.get_popular_tags = async (event, context, callback) => {
    context.callbackWaitsForEmptyEventLoop = false;

    try {
        await connect_to_db();
        console.log('=> fetching popular tags');

        const result = await talk.aggregate([
            { $unwind: "$tags" },
            { $group: { _id: "$tags", count: { $sum: 1 } } },
            { $sort: { count: -1 } },
            { $limit: 10 }
        ]);

        const formatted = result.map(tag => ({
            tag: tag._id,
            count: tag.count
        }));

        return callback(null, {
            statusCode: 200,
            body: JSON.stringify(formatted)
        });

    } catch (err) {
        console.error('Error fetching popular tags:', err);
        return callback(null, {
            statusCode: err.statusCode || 500,
            headers: { 'Content-Type': 'text/plain' },
            body: 'Could not fetch popular tags.'
        });
    }
};