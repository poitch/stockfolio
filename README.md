Description
===========

Track your stock portfolio and stock watchlist from the command line.

This mainly leverages the Google Finance data, it is not using the GData Google Finance API though, and is not storing your portfolio information in Google. Read the motivation.

Install
=======

    $ gem install stockfolio

Usage
=====

Search for a stock

    $ ./bin/stockfolio search "Tesla Motors"
    +-------------+---------------------------+
    | Symbol      | Name                      |
    +-------------+---------------------------+
    | NASDAQ:TSLA | Tesla Motors Inc          |
    | FRA:TL0     | TESLA MOTORS INC. DL-,001 |
    +-------------+---------------------------+
    2 rows in set

Adding stock to the watch list

    $ stockfolio watch NASDAQ:AAPL
    Added NASDAQ:AAPL to watchlist - current price $602.50

See today's performance for the watch list

    $ stockfolio watchlist
    +--------+------------+----------------+
    | Symbol | Last Price | Change         |
    +--------+------------+----------------+
    | AAPL   | $602.50    | -3.46 (-0.57%) |
    +--------+------------+----------------+
    1 row in set

Removing stock from the watch list

    $ stockfolio unwatch NASDAQ:AAPL

Check historical data

    $ stockfolio historical NASDAQ:AAPL 2011-12-25 2011-12-31
    +------------+--------+--------+--------+--------+---------+
    | date       | open   | close  | low    | high   | volume  |
    +------------+--------+--------+--------+--------+---------+
    | 2011-12-30 | 405.00 | 405.00 | 405.00 | 405.00 | 0       |
    | 2011-12-29 | 403.40 | 405.12 | 400.51 | 405.65 | 7719863 |
    | 2011-12-28 | 406.89 | 402.64 | 401.34 | 408.25 | 8173461 |
    | 2011-12-27 | 403.10 | 406.53 | 403.02 | 409.09 | 9472659 |
    +------------+--------+--------+--------+--------+---------+
    4 rows in set

Create a portfolio

    $ stockfolio create 401k
    Created portfolio "401k"

Add a buy transaction to portfolio

    $ stockfolio buy --portfolio 401k --symbol NASDAQ:AAPL --price 602.50 --quantity 10 --fee 9.99 --date 2012/03/20
    Added BUY  of 10 NASDAQ:AAPL to 401k

See your current position

    $ stockfolio positions 401k
    +--------+------------+----------------+------------+--------+------------+--------------+--------+--------+
    | Symbol | Last Price | Change         | Day's Gain | Shares | Cost Basis | Market Value | Gain   | Gain % |
    +--------+------------+----------------+------------+--------+------------+--------------+--------+--------+
    | AAPL   | $602.5     | -3.46 (-0.57%) | -34.6      | 10     | $6034.99   | $6025.0      | $-9.99 | -0.2%  |
    +--------+------------+----------------+------------+--------+------------+--------------+--------+--------+
    
    
    # all combined positions
    $ stockfolio positions
    +--------+------------+----------------+------------+--------+------------+--------------+--------+--------+
    | Symbol | Last Price | Change         | Day's Gain | Shares | Cost Basis | Market Value | Gain   | Gain % |
    +--------+------------+----------------+------------+--------+------------+--------------+--------+--------+
    | AAPL   | $602.5     | -3.46 (-0.57%) | -34.6      | 10     | $6034.99   | $6025.0      | $-9.99 | -0.2%  |
    +--------+------------+----------------+------------+--------+------------+--------------+--------+--------+

See list of transactions

    $ stockfolio transactions 401k

Delete a transaction

    $ stockfolio delete transaction 401k 1

Delete a portfolio

    $ stockfolio delete portfolio 401k
 
Configuration
=============

Configure stockfolio with a ~/.stockfolio.yml, which is loaded before every command request.

For example, to configure where the database is stored:
    
    #
    db: ~/Dropbox/.stockfolio.db

By default the database file is stored in ~/.stockfolio.db

Motivation
==========

After seeing all that user tracking news regarding Google, I've decided to not be logged in on google when doing searches, which meant moving away from a few tools for me including Google Finance and particularly the Portfolio section, which gave me a nice quick glance at my stock portfolio.

For a while I was not sure of which form the replacement would take and after running into Hirb and Boson, I decided that a command line tool was just going to be fine, I could store the database file where I want

TODO
====

Encrypting database file
Rework buy/sell commands
Support for short sell and buy to cover


