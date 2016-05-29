debug = (require 'debug') 'test'
Parser = require './parser'

Parser.parseMessage '177e19cafed83338c31a05ba', 'Rouven', 'I am seeing Ami'
#Parser.parseMessage '177e19cafed83338c31a05ba', 'Rouven', 'Where is Rouven?'