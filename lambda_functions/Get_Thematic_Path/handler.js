const connect_to_db = require('./db');
const talk = require('./Talk');

module.exports.get_thematic_path = async (event, context, callback) => {
  context.callbackWaitsForEmptyEventLoop = false;

  let body = {};
  if (event.body) {
    body = JSON.parse(event.body);
  }

  const tag = body.tag;
  const maxDuration = body.max_duration; // in minuti

  if (!tag || !maxDuration) {
    return callback(null, {
      statusCode: 400,
      headers: { 'Content-Type': 'text/plain' },
      body: 'Missing tag or max_duration.'
    });
  }

  try {
    await connect_to_db();

    // Fetch talks with the specified tag
    const talks = await talk.find({ tags: tag }).lean();

    // Sort by duration ascending
    const sortedTalks = talks
      .filter(t => t.duration && !isNaN(t.duration))
      .sort((a, b) => parseInt(a.duration) - parseInt(b.duration));

    let selectedTalks = [];
    let totalDuration = 0;

    for (const t of sortedTalks) {
      const dur = parseInt(t.duration);
      if (totalDuration + dur <= maxDuration) {
        selectedTalks.push(t);
        totalDuration += dur;
      } else {
        break;
      }
    }

    return callback(null, {
      statusCode: 200,
      body: JSON.stringify(selectedTalks.map(t => ({
        title: t.title,
        url: t.url,
        duration: t.duration,
        speakers: t.speakers,
        keyPhrases: t.comprehend_analysis?.KeyPhrases || []
      })))
    });

  } catch (err) {
    console.error('Error in get_thematic_path:', err);
    return callback(null, {
      statusCode: 500,
      headers: { 'Content-Type': 'text/plain' },
      body: 'Internal Server Error'
    });
  }
};