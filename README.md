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

See today's performance for the watch list

    $ stockfolio watchlist

Create a portfolio

    $ stockfolio create 401k

Add a buy transaction to portfolio

    $ stockfolio buy --portfolio 401k --symbol NASDAQ:AAPL --price 600 --quantity 10 --fee 9.99 --date 2012/03/20

See your current position

    $ stockfolio positions 401k
    
    # all combined positions
    $ stockfolio positions

Configuration
=============

Configure stockfolio with a ~/.stockfolio.yml, which is loaded before every command request.

For example, to configure where the database is stored:
    db: ~/Dropbox/.stockfolio.db

By default the database file is stored in ~/.stockfolio.db

