# bbc-crawler

## Dependencies

- [grab-site](https://github.com/ArchiveTeam/grab-site)
- [lynx](https://formulae.brew.sh/formula/lynx)
- [Archives Unleashed Toolkit](https://github.com/archivesunleashed/aut)

 
## Example Usage

Target site to be crawled: https://www.bbc.com/gahuza

Clone the repo:

```shell
git clone https://github.com/yxzhu16/bbc-crawler.git
cd bbc-crawler
```
First, start the grab-site dashboard with:

```
gs-server
```

and point your browser to http://127.0.0.1:29000/

Create an input.txt file to list urls for all sections. See example-input.txt for an example. For multi-page sections, put a placeholder {n} followed by a whitespace and the total number of pages. 

Run get_pages.sh
```shell
./get_pages.sh gahuza example-input.txt
```

This will first generate two .txt files:
- catalog.txt: expand the input.txt as regular URLs
- gahuza_pages_url.txt: URLs for all article pages to be crawled

And then it started to crawl using `gahuza_pages_url.txt` and store the result into a folder.

The crawling process can take several hours, depending on the size of the site.

You will be able to replay the entire site using [ReplayWeb.page](https://replayweb.page), a webapp for replaying warc files. Load the WARC file (the one ending with 0000.warc.gz) and you are good to go. For details, please check its [doc](https://replayweb.page/docs/loading).

If you would like to extract plain text using [AUT](https://github.com/archivesunleashed/aut):

1. Clone and build the toolkit following its instructions

2. Use the toolkit with Jupyter
`export PYSPARK_DRIVER_PYTHON=jupyter; export PYSPARK_DRIVER_PYTHON_OPTS=notebook; pyspark --py-files path/to/aut/target/aut.zip --jars path/to/aut/target/aut-0.80.1-SNAPSHOT-fatjar.jar`

For other usages, check https://aut.docs.archivesunleashed.org/docs/usage

3. In the cell enter:
``` 
from aut import *
from pyspark.sql.functions import col, explode, monotonically_increasing_id

archive_history = WebArchive(sc, sqlContext, "path/to/wa
rc")
src_url_pattern = "www.bbc.com/gahuza"  # You can also use regular expression. For Pidgin, I used "www.bbc.com/pidgin/.*[0-9][0-9][0-9]$"

pages = archive_history.webpages().filter(col("url").rlike(src_url_pattern))
distinctPages = pages.dropDuplicates(["url"])
distinctPages.select(remove_html(remove_http_header("content")).alias("content")) \
.write.csv("plain-text")
```
For other text-analysis methods, check https://aut.docs.archivesunleashed.org/docs/text-analysis

## Historical Data
Following the above instructions, you can crawl pages that are currently hosted on the website. For historical pages, you can make use of Wayback Machine. 

Take gahuza as an example,
1. Crawl https://web.archive.org/web/*/https://www.bbc.com/gahuza
2. Use lynx or AUT to extract links
3. Crawl those page links

## Other methods tried
I tried various tools to crawl sites and view the crawled warc files, and summarized what I found in [this doc](
https://docs.google.com/document/d/1clAryFqRYoNsITGJxHiMHCBMPhgiEZpxulN45CyMciM/edit?usp=sharing)

tl;dr: I picked grab-site to crawl the sites and Replayweb.page to replay the sites. 

