_                      = require "underscore"
assert                 = require "assert"
async                  = require "async"
{ MongoClient }        = require "mongodb"
{ Readable, Writable } = require "stream"

StreamCombine = require "../src/StreamCombine"

class TestStream extends Readable
	constructor: (@serie) ->
		super objectMode: true
		@push point for point in @serie
		@push null

	_read: ->

class SlowWritableStream extends Writable
	constructor: ->
		super objectMode: true

	_write: (obj, encoding, cb) ->
		setTimeout =>
			@emit "obj"
			cb()
		, 1

checkSeries = (series, expected, done) ->
	str = ""
	sb  = new StreamCombine (new TestStream serie for serie in series), "_id"
	sb.on "data", (data) ->
		str += JSON.stringify data
	sb.on "end", ->
		assert.equal str, expected if expected
		done()

randomTestData = ->
	data = []

	for i in [1..1000]
		prevId = data[data.length - 1]?._id or Math.ceil Math.random() * 10

		id = prevId + Math.ceil Math.random() * 10

		# data.push
		# 	_id:   id
		# 	value: id
		data.push
			_id:   prevId + Math.ceil Math.random() * 10
			value: Math.round(Math.random() * 1000)

	data

flatTestData = ->
	data = []

	for i in [1..1000]
		data.push
			_id:   i
			value: i

	data

linearTestData = ->
	data = []

	mutliplier = Math.random()

	for i in [1..Math.ceil mutliplier * 10]
		value = Math.floor i * mutliplier * 4
		data.push
			_id:   value
			value: value

	data

describe "StreamCombine", ->

	describe "constructor", ->
		describe "when the streams argument is not defined", ->
			it "should throw an error", (done) ->
				assert.throws ->
					new StreamCombine
				, /Streams argument is required/

				done()

		describe "when streams is not an Array", ->
			it "should throw an error", (done) ->
				assert.throws ->
					new StreamCombine {}
				, /Streams should be an Array/

				done()

		describe "when the streams array is empty", ->
			it "should throw an error", (done) ->
				assert.throws ->
					new StreamCombine []
				, /Streams array should not be empty/

				done()

		describe "when the key argument is not defined", ->
			it "should throw an error", (done) ->
				assert.throws ->
					new StreamCombine [1]
				, /Key argument is required/

				done()

	describe "integration", ->
		describe "one series of data", ->
			it "should be equal as expected", (done) ->
				series   = [[ { _id: 1, 11 }, { _id: 2, 12 }, { _id: 3, 13 }, { _id: 4, 14 }, { _id: 5, 15 } ]]

				expected = '{"data":[{"11":11,"_id":1}],"indexes":[0],"_id":1}{"data":[{"12":12,"_id":2}],"indexes":[0],"_id":2}{"data":[{"13":13,"_id":3}],"indexes":[0],"_id":3}{"data":[{"14":14,"_id":4}],"indexes":[0],"_id":4}{"data":[{"15":15,"_id":5}],"indexes":[0],"_id":5}'

				checkSeries series, expected, done

		describe "two series of data", ->
			describe "evenly distributed", ->
				it "should be equal as expected", (done) ->
					series = []
					series.push [ { _id: 1, 11 }, { _id: 2, 12 }, { _id: 3, 13 }, { _id: 4, 14 }, { _id: 5, 15 } ]
					series.push [ { _id: 1, 11 }, { _id: 2, 12 }, { _id: 3, 13 }, { _id: 4, 14 }, { _id: 5, 15 } ]

					expected = '{"data":[{"11":11,"_id":1},{"11":11,"_id":1}],"indexes":[0,1],"_id":1}{"data":[{"12":12,"_id":2},{"12":12,"_id":2}],"indexes":[0,1],"_id":2}{"data":[{"13":13,"_id":3},{"13":13,"_id":3}],"indexes":[0,1],"_id":3}{"data":[{"14":14,"_id":4},{"14":14,"_id":4}],"indexes":[0,1],"_id":4}{"data":[{"15":15,"_id":5},{"15":15,"_id":5}],"indexes":[0,1],"_id":5}'

					checkSeries series, expected, done

			describe "unevenly distributed", ->
				it "should be equal as expected", (done) ->
					series = []
					series.push [ { _id: 1, 11 }, { _id: 2, 12 }, { _id: 3, 13 },                { _id: 5, 15 }                ]
					series.push [                { _id: 2, 12 }, { _id: 3, 13 }, { _id: 4, 14 }, { _id: 5, 15 }, { _id: 5, 15 } ]

					expected = '{"data":[{"11":11,"_id":1}],"indexes":[0],"_id":1}{"data":[{"12":12,"_id":2},{"12":12,"_id":2}],"indexes":[0,1],"_id":2}{"data":[{"13":13,"_id":3},{"13":13,"_id":3}],"indexes":[0,1],"_id":3}{"data":[{"14":14,"_id":4}],"indexes":[1],"_id":4}{"data":[{"15":15,"_id":5},{"15":15,"_id":5}],"indexes":[0,1],"_id":5}{"data":[{"15":15,"_id":5}],"indexes":[1],"_id":5}'

					checkSeries series, expected, done

		describe "multiple series of data", ->
			describe "unevenly distributed", ->
				it "should work", (done) ->
					series = [
						[ { _id: 1, 11 }, { _id: 2, 12 }, { _id: 3, 13 },                 { _id: 5, 15 }                ]
						[                { _id: 2, 12 },                                { _id: 5, 15 }, { _id: 6, 15 } ]
						[                { _id: 2, 12 },                { _id: 4, 14 }                                ]
						[                { _id: 2, 12 }, { _id: 3, 13},                  { _id: 5, 15 }, { _id: 6, 15 } ]
					]

					checkSeries series, null, done

				it "should work", (done) ->
					series = [
						[{ _id: 1, value: 1 }, { _id: 2, value: 2 }, { _id: 3, value: 3 },                       { _id: 5, value: 5 } ]
						[                      { _id: 2, value: 2 },                       { _id: 4, value: 4 },                         { _id: 7, value: 7 }, { _id: 9, value: 9 }, { _id: 12, value: 12 }, { _id: 14, value: 14 }, { _id: 17, value: 17 } ]
					]

					checkSeries series, null, done


	describe "large amounts", ->
		describe "handle it", ->
			it "should work with flat data", (done) ->
				series = []
				for i in [1..4]
					series.push flatTestData()
					# series.push randomTestData()

				sb  = new StreamCombine (new TestStream serie for serie in series), "_id"
				sb.on "data", (data) ->
				sb.on "end", ->
					done()

			it "should work with flat linear", (done) ->
				series = []
				for i in [1..5]
					series.push linearTestData()
					# series.push randomTestData()

				sb  = new StreamCombine (new TestStream serie for serie in series), "_id"
				sb.on "data", (data) ->
				sb.on "end", ->
					done()

	describe "piped stream", ->
		describe "handle it - slow writable", ->
			it "should work with flat linear", (done) ->
				@timeout 5000

				series = []
				for i in [1..8]
					series.push randomTestData()

				sc = new StreamCombine (new TestStream serie for serie in series), "_id"
				sw = new SlowWritableStream

				count = 0

				sw.on "obj", ->
					if ++count is 2000
						sc.unpipe()
						done()

				sc.pipe sw

	describe "mongodb cursor streams", ->

		count           = 0
		now             = null
		database        = null
		collectionNames = ("test-#{i}" for i in [1..10])

		before (done) ->
			@timeout 10000

			MongoClient.connect "mongodb://localhost:27017/stream-combine-test", (error, db) ->
				throw error if error

				database = db

				insertTestData = (collectionName, cb) ->
					testData = randomTestData()
					# console.log "Inserting #{testData.length} documents into collection #{collectionName}..."

					database.collection collectionName, (error, collection) ->
						return cb error if error

						collection.remove {}, (error) ->
							return cb error if error

							collection.insertMany testData, (error) ->
								return cb error if error

								# console.log "Done."

								cb()

				async.each collectionNames, insertTestData, (error) ->
					throw error if error

					now = Date.now()
					console.log "inserted"

					done()

		after (done) ->
			@timeout 10000

			database.dropDatabase (error) ->
				throw error if error

				database.close()

				done()

		describe "stream all collections", ->
			it "should work", (done) ->
				@timeout 10000

				streams = []

				addCollectionStream = (collectionName, cb) ->
					database.collection collectionName, (error, collection) ->
						return cb error if error

						streams.push collection.find().stream()

						cb()

				async.each collectionNames, addCollectionStream, (error) ->
					throw error if error

					sb  = new StreamCombine streams, "_id"
					sb.on "data",  (data) ->
						count++
						# console.log data
					sb.on "error", (error) -> throw error
					sb.on "end", ->
						seconds = (Date.now() - now) / 1000
						console.log "#{seconds.toFixed 2} s, #{count} elements, #{(10000 / seconds).toFixed 2} elements/s"
						done()


