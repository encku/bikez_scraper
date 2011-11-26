require 'rubygems'
require 'pg'
require 'nokogiri'
require 'open-uri'

def make_model_for(year)
  doc = Nokogiri::HTML(open("http://www.bikez.com/year/index.php?year=#{year}"))

  tables = doc.css('body table table')
  model_table = tables[7] # check structure of site for magic number...

  # remove ads
  model_table.css('tr td script').each do |script|
    script.xpath('./ancestor::td[1]').remove
  end

  # we now are left with trs with 3 tds a piece...
  # except for the ones next to the ads, which have a pattern of 1 td, 2 tds,
  # 1 td, 2 tds... 
  # also the first row is just a header, we can skip it

  rows = model_table.css('tr')
  results = []
  # skip the first row, it is garbage
  @size = rows.size
  @i = 1
  while @i < @size do
    row = rows[@i]
    
    children = row.children
    # if was a row that previously had an ad, grab relevant data from this and the next row
    if (children.size == 3)
      model = children[0].text
      make = children[1].text
    else
      model = children[0].text
      make = row.next_sibling.children[0].text
      @i += 1
    end
    results.push([make, model])
    @i += 1
  end
  return results
end

puts make_model_for(1997)
