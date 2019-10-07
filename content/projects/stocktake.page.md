# Stocktake

_Available on [GitHub](https://github.com/kdelwat/stocktake)._

**Note: on June 1st, 2019, IEX removed 3rd-party data from its API and broke this project. I may or may not fix it in the future.**

Stocktake.xyz is an extremely minimal site for financial market data. It supports shares on multiple exchanges like IEX and NASDAQ as well as cryptocurrencies and futures.

{{< figure src="/images/Stocktake-Home.png" title="The Stocktake home screen" alt="The Stocktake home screen">}}

The site is built with hand-written HTML and CSS. There is no preprocessor or client-side JavaScript, making pages tiny (the homepage is 4.6 KB). Pages are server-side rendered with Node.js, [hapi](https://hapijs.com/), and [node-chartist](https://github.com/panosoft/node-chartist) for SVG graphs.

Data is retrieved on-demand from the [IEX API](https://iextrading.com/developer/docs/). Unfortunately, this API can be quite slow, so Stocktake is backed by a Redis store to cache the results of common queries and improve speed.

All pages are responsive and work across major browsers and devices.

{{< figure src="/images/Stocktake-Stock.png" title="Information about a stock on desktop" alt="Information about a stock on desktop">}}

{{< figure src="/images/Stocktake-Mobile.png" title="Information about a stock on mobile" alt="Information about a stock on mobile">}}

Stocktake also supports fuzzy-searching on company names and stock symbols, using [fuse.js](https://fusejs.io/).

{{< figure src="/images/Stocktake-Search.png" title="The results of a search" alt="The results of a search">}}
