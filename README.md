Description
===========

Track your stock portfolio and stock watchlist from the command line.

Install
=======

    $ gem install stockfolio

Usage
=====

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

Configuration
=============

Configure stockfolio with a ~/.stockfolio.yml, which is loaded before every command request.

For example, to configure where the database is stored:
    
    #
    db: ~/Dropbox/.stockfolio.db

By default the database file is stored in ~/.stockfolio.db

