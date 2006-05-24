#!/usr/bin/env ruby
# DavazMySQL -- davaz.com -- 22.08.2005 -- mhuggler@ywesee.com

$: << File.expand_path("../", File.dirname(__FILE__))

require 'mysql'
require 'fileutils'
require 'yaml'
require 'iconv'
require 'rexml/document'
require 'scripts/parse_html'

module DavazMySQL
	OLD_DAVAZ_DIR = 'davaz.com'
	module Table
		class Table 
			def table_name
				[self.class.to_s.split("::").last.downcase, 's'].join
			end
			def join_values
				values.collect { |value| 
					unless(value == "" || value.nil?)
						"\'"+Mysql.escape_string(value)+"\'" 
					else
						"\'\'"
					end
				}.join(",")
			end
			def values
				[]
			end
		end
		class NameTable < Table
			attr_accessor :id, :name
			def values
				[
					id,
					name,
				]
			end
		end
		class ArtObject < Table
			attr_accessor :artobject_id, :artgroup_id
			attr_accessor :tool_id, :material_id, :country_id, :date
			attr_accessor :serie_id, :serie_nr, :size, :location, :language
			attr_accessor :title, :public, :comment
			attr_accessor :initial, :contractions, :changeat, :type
			attr_accessor :price
			attr_reader :links
			def table_name
				'artobjects'
			end
			def initialize(artobject_id=nil)
				@artobject_id = artobject_id
				@links = []
			end
			def values
				[
					artobject_id,
					artgroup_id,
					tool_id,
					material_id,
					country_id,
					date,
					serie_id,
					serie_nr,
					size,
					location,
					language,
					title,
					public,
					type,
					comment,
					price,
				]
			end
		end
		class ArtObjectDisplayElement < Table
			attr_accessor :artobject_id, :display_id
			def table_name
				'artobjects_displayelements'
			end
			def values
				[
					artobject_id,
					display_id,
				]
			end
		end
		class LinkDisplayElement < Table
			attr_accessor :link_id, :display_id
			def table_name
				'links_displayelements'
			end
			def values
				[
					link_id,
					display_id,
				]
			end
		end
		class Country < Table
			attr_accessor :country_id, :name
			def table_name
				'countries'
			end
			def values
				[
					country_id,
					name,
				]
			end
		end
		class Currency < Table
			attr_accessor :origin, :target, :rate
			def table_name
				'currencies'
			end
			def value
				[
					origin,
					target,
					rate
				]
			end
		end
		class DisplayElement < Table
			attr_accessor :display_id, :title, :text, :author, :date, :type, :location, :position, :charset
			attr_reader :links
			def initialize
				@links = []
			end
			def table_name
				'displayelements'
			end 
			def values
				[
					display_id,
					title,
					text,
					author,
					date,
					type,
					location,
					position,
					charset,
				]
			end
		end
		class DisplayElementDisplayElement < Table
			attr_accessor :display_id, :to_display_id
			attr_reader :links
			def table_name
				'displayelements_displayelements'
			end 
			def values
				[
					display_id,
					to_display_id,
				]
			end
		end
		class Link < Table
			attr_accessor :link_id, :display_id, :word
			attr_accessor :href, :type
			attr_accessor :poem_links
			def initialize
				@poem_links = {}
			end
			def table_name
				'links'
			end 
			def values
				[
					link_id,
					display_id,
					word,
					href,
					type,
				]
			end
		end
		class Guestbook < Table
			attr_accessor :date, :firstname, :lastname, :city, :country
			attr_accessor :email, :text
			def table_name
				'guestbook'
			end
			def values
				[
					'',
					date,
					firstname,
					lastname,
					city,
					country,
					email,
					text,
				]
			end
		end
		class Material < NameTable; end
		class OneLiner < Table
			attr_accessor :text, :location, :color, :size, :active
			def table_name
				'oneliner'
			end
			def values
				[
					'',
					text,
					location,
					color,
					size,
					active,
				]
			end
		end
		class Serie < Table
			attr_accessor :serie_id, :name
			def values
				[
					serie_id,
					name,
				]
			end
		end
=begin
		class Shop < Table
			attr_accessor :artobject_id, :name, :price, :dollars, :artgroup_id
			attr_accessor :html, :text, :shop_item_id
			def table_name
				'shop'
			end
			def values
				[
					shop_item_id,
					artobject_id,
					name,
					price,
					dollars,
					artgroup_id,
					html,
					text,
				]
			end
		end
		class SlideShow < Table
			attr_accessor :slideshow_id, :title
			def table_name
				'slideshows'
			end
			def values
				[
				 slideshow_id,
				 type,
				 title,
				]
			end
		end 
=end
		class SlideShowItem < Table
			attr_accessor :slideshow_item_id, :slideshow, :display_id, :position
			def table_name
				'slideshow_items'
			end
			def values
				[
					slideshow_item_id,
					slideshow,
					display_id,
					position,
				]
			end
		end
		class Tool < NameTable; end
	end
	class XML
		attr_reader :tables
		def initialize(mysql_objects, ids, linktableitems)
			@tables = {}
			@mysql_objects = mysql_objects
			@ids = ids
			@linktableitems = linktableitems
		end
		def create_doc(file)
			file = File.new(File.expand_path("../../#{OLD_DAVAZ_DIR}/doc/xml/data/#{file}", File.dirname(__FILE__)))
			@doc = REXML::Document.new(file)
		end
		def get_news_tables
			create_doc('news.xml')
			@doc.elements.to_a("//entry").each { |entry|
				table = Table::DisplayElement.new 
				timestamp = entry.attributes['timestamp']
				table.date = Time.at(timestamp.to_i).strftime("%Y-%m-%d")
				table.title = entry.children[1].text
				table.text = entry.children[3].text
				table.type = 'news-item'
				table.location = 'news'
				image = entry.children[5].attribute('name')
				lti = GetMySQLData::LinkTableItem.new
				lti.type = 'image'
				lti.src_dir = 'images/news'
				lti.src_file = image
				lti.linked_to = :displayelements
				table.links.push(lti)
				@mysql_objects.send(table.table_name).push(table)
			}
		end
		def get_guestbook_tables
			create_doc('guestbook.xml')
			@doc.elements.to_a("//entry").each { |entry|
				table = Table::Guestbook.new 
				timestamp = entry.attributes['timestamp']
				table.date = Time.at(timestamp.to_i).strftime("%Y-%m-%d")
				table.firstname = entry.children[1].children[1].children[1].text
				table.lastname = entry.children[1].children[1].children[3].text
				table.city = entry.children[1].children[3].children[1].text
				table.country = entry.children[1].children[3].children[3].text
				table.email = entry.children[1].children[5].text
				table.text = entry.children[3].text
				@mysql_objects.send(table.table_name).push(table)
			}
		end
		def get_link_tables
			create_doc('links.xml')
			@doc.elements.to_a("//link").each { |entry|
				table = Table::DisplayElement.new 
				timestamp = entry.attributes['timestamp']
				table.date = Time.at(timestamp.to_i).strftime("%Y-%m-%d")
				table.title = entry.children[1].text
				table.text = enc(entry.children[3].text)
				table.type = 'urllink'
				table.location = 'links'
				@mysql_objects.send(table.table_name).push(table)
			}
		end
		def shop_text
			one = <<-EOS
			377 pages with 4 folding plates, 180 color and 175 black and -white illustrations\r\n
			Editor: Bjarne Geiges, München
			Editor of the chinese edition Adrian Geiges and Qu Yan, New York
			© 1999 for the bookstore edition Benteli publisher
			© 1999 for text and art-work
			Da Vaz productions All rights reserverd
			
			German edition published 1998 Translated into chinese and english 1999 English translation by John M. King Chinese translation by Qu Yan-Geiges
			
			Photographic credits: Bjarne Geiges
			Design: Bjarne Geiges, Ursula Davatz
			Binding: Schumacher AG, Schmitten, Switzerland
			Printing: Benteli Verlag, Bern, Switzerland
			Book cover: Ariuscha Davatz
			
			Standard edition
			Paperback, 24*30 cm
			CHF 120. --/DM 140.-/öS 1022.-
			ISBN 3-7165-1129-3"
			EOS
			two = <<-EOS
			376 pages with 4 folding plates, 180 color and 175 black and -white illustrations
			Editor: Bjarne Geiges, München
			Editor of the chinese edition: Adrian Geiges and Qu Yan, New York

			© 1999 for the bookstore edition Benteli publisher
			© 1999 for text and art-work
			Da Vaz productions All rights reserverd

			German edition published 1998
			Translated into chinese and english 1999
			English translation by John M. King
			Chinese translation by Qu Yan-Geiges

			Photographic credits: Bjarne Geiges
			Design: Bjarne Geiges, Ursula Davatz
			Binding: Schumacher AG, Schmitten, Switzerland
			Printing: Benteli Verlag, Bern, Switzerland
			Book cover: Ariuscha Davatz

			Numbered and signed edition
			cloth binding, with slip-case
			CHF 240. --/DM 280.-/öS 2000.-
			ISBN 3-7165-1159-5
			EOS
			three = <<-EOS
			376 pages with 4 folding plates, 180 color and 175 black and -white illustrations
			Editor: Bjarne Geiges, München
			Editor of the chinese edition Adrian Geiges and Qu Yan, New York

			© 1999 for the bookstore edition Benteli publisher
			© 1999 for text and art-work
			Da Vaz productions All rights reserverd

			German edition published 1998
			Translated into chinese and english 1999
			English translation by John M. King
			Chinese translation by Qu Yan-Geiges1

			Photographic credits: Bjarne Geiges
			Design: Bjarne Geiges, Ursula Davatz
			Binding: Schumacher AG, Schmitten, Switzerland
			Printing: Benteli Verlag, Bern, Switzerland
			Book cover: Ariuscha Davatz

			Edition with an original drawing
			numbered and signed limited on 50 copies
			cloth binding, with slip-case
			CHF 780. --/DM 890.-/öS 6500.-
			ISBN 3-7165-1159-5
			EOS
			four = <<-EOS
			Rapidograph drawings, ink on canvas, 1978 published in Washington, D.C., USA, limited edition to 300 copies, numbered and signed
			EOS
			five = <<-EOS
			162 pages with 1 folding plate. 74 black-and-white illustrations One drawing in 5 sections, 1980 published in Washington, D.C., USA, limited edition to 300 copies, numbered and signed 	
			EOS
			six = <<-EOS
			116 pages 47 black-and-white illustrations Ball-point pen and rapidograph drawings on paper. 1975 published in Basel, Switzerland
			EOS
			seven = <<-EOS
			35 postcards, published in Strasbourg, France
			EOS
			{
				'1' =>	one,
				'2'	=>	two, 
				'3'	=>	three,	
				'4'	=>	four,
				'5'	=>	five,
				'6'	=>	six,
				'7'	=>	seven,
			}
		end
		def shop_images
			{
				'1'		=>	'wunderblock',
				'2'		=>	'wunderblock',
				'3'		=>	'wunderblock',
				'4'		=>	'psychospheres',
				'11'	=>	'prixdebale',
				'44'	=>	'paletteone,palettetwo,palettethree,palettefour',
			}
		end
		def enc2utf8(string)
			Iconv.iconv('utf8', 'latin1', string).first
		end
		def get_shop_tables
			create_doc('order.xml')
			@doc.elements.to_a("//artikel").each { |entry|
				unless(entry.attributes['artgroup']=='Films')
					table = Table::ArtObject.new 
					number = entry.attributes['artnummer']
					#@ids.add_shop_item
					#table.shop_item_id = @ids.shop_item
					#table.artobject_id = entry.attributes['artnummer']
					table.title = entry.attributes['name']
					table.price = entry.attributes['franken']
					table.artgroup_id = entry.attributes['artgroup'].upcase[0,3]
					if(text = shop_text[number])
						table.comment = enc2utf8(text)
					else
						table.comment = ''
					end
					if(images = shop_images[number])
						shop_images[number].split(",").each { |image| 
							lti = GetMySQLData::LinkTableItem.new
							lti.type = 'image'
							lti.title = table.title
							#lti.link_id = @ids.shop_item
							lti.src_dir = 'images/shop'
							lti.src_file = image
							lti.linked_to = :artobjects
							table.links.push(lti)
						}
					end
					@mysql_objects.send(table.table_name).push(table)
				end
			}
		end
		def enc(string)
			string
			#Iconv.iconv('latin1', 'utf8', string).first
			Iconv.iconv('utf8', 'latin1', string).first
		end
	end
	class PrepareNewDatabase
		def initialize(mysql_connection)
			@mysql_connection = mysql_connection
		end
		def startquery(table)
			drop_query = "DROP TABLE IF EXISTS #{table};"
			@mysql_connection.query(drop_query)
			puts "creating again #{table}..."
			@mysql_connection.query(self.send(table))
		end
		def guestbook 
			<<-EOS
CREATE TABLE guestbook ( 
  guest_id int(6) unsigned NOT NULL auto_increment,
	date date NOT NULL default '1901-01-01',
	firstname varchar(60)	NOT NULL default '',
	lastname varchar(60)	NOT NULL default '',
	city varchar(60)	NOT NULL default '',
	country varchar(60)	NOT NULL default '',
	email varchar(80)	NOT NULL default '',
	text text NOT NULL,
  PRIMARY KEY (guest_id),
	KEY id (guest_id)
) TYPE=MyISAM;
			EOS
		end
		def artobjects 
			<<-EOS
CREATE TABLE artobjects ( 
  artobject_id int(6) unsigned NOT NULL auto_increment,
	artgroup_id char(3) NOT NULL default '',
	tool_id tinyint(4) unsigned NOT NULL default '0',
	material_id tinyint(4) unsigned NOT NULL default '0',
	country_id char(3) NOT NULL default '',
	date date NOT NULL default '1901-01-01',
	serie_id char(3) NOT NULL default '',
	serie_nr tinyint(4) unsigned NOT NULL default '0',
	size varchar(50) default NULL,
	location varchar(50) default NULL,
	language varchar(150) default NULL,
	title varchar(150) default NULL,
	public tinyint(1) unsigned NOT NULL default '1',
	type ENUM( 'original', 'trailor', 'none') NOT NULL default 'none',
	comment text NOT NULL,
  price int(10) unsigned NULL,
  PRIMARY KEY (artobject_id),
  KEY artcode (artgroup_id,tool_id,material_id,country_id,date,serie_id,serie_nr,public)
) TYPE=MyISAM;
			EOS
		end
		def artobjects_displayelements
			<<-EOS
CREATE TABLE artobjects_displayelements (
	artobject_id int(6) NOT NULL,
	display_id int(6)	NOT NULL,
	PRIMARY KEY (artobject_id,display_id)
) TYPE=MyISAM;
			EOS
		end
		def links_displayelements
			<<-EOS
CREATE TABLE links_displayelements (
	link_id int(6) NOT NULL,
	display_id int(6)	NOT NULL,
	PRIMARY KEY (link_id,display_id)
) TYPE=MyISAM;
			EOS
		end
=begin
		def shop_displayelements
			<<-EOS
CREATE TABLE shop_displayelements (
	shop_item_id int(6) NOT NULL,
	display_id int(6)	NOT NULL,
	PRIMARY KEY (shop_item_id,display_id)
) TYPE=MyISAM;
			EOS
		end
=end
		def artgroups 
			<<-EOS
CREATE TABLE artgroups ( 
  artgroup_id char(3) NOT NULL default 'AAA',
	name varchar(50) NOT NULL default '',
	shop_order tinyint(3) NOT NULL default '',
	PRIMARY KEY (artgroup_id),
	KEY id (artgroup_id,name)
) TYPE=MyISAM;
			EOS
		end
		def countries
			<<-EOS
CREATE TABLE countries ( 
	country_id char(3) NOT NULL default 'AAA',
	name varchar(50) NOT NULL default '',
	PRIMARY KEY (country_id),
	KEY id (country_id,name)
) TYPE=MyISAM;
			EOS
		end
		def currencies 
			<<-EOS
CREATE TABLE currencies ( 
	origin char(4) NOT NULL,
	target char(4) NOT NULL,
	rate float(20,18) unsigned NOT NULL,
	KEY id (origin,target)
) TYPE=MyISAM;
			EOS
		end
		def displayelements 
			<<-EOS
CREATE TABLE displayelements ( 
  display_id int(6) unsigned NOT NULL auto_increment,
	title varchar(100) NOT NULL default '',
	text text NOT NULL,
	author varchar(60) NOT NULL default '',
	date date NOT NULL default '1901-01-01',
	type varchar(60)	NOT NULL default '',
	location varchar(60)	NOT NULL default '',
	position varchar(60) NOT NULL default '',
	charset varchar(10)	NULL,
  PRIMARY KEY (display_id),
	KEY id (display_id)
) TYPE=MyISAM;
			EOS
		end
		def displayelements_displayelements
			<<-EOS
CREATE TABLE displayelements_displayelements (
	display_id int(6) NOT NULL,
	to_display_id int(6)	NOT NULL,
	PRIMARY KEY (display_id,to_display_id)
) TYPE=MyISAM;
			EOS
		end
		def links 
			<<-EOS
CREATE TABLE links ( 
  link_id int(6) unsigned NOT NULL auto_increment,
	display_id int(6) NOT NULL default '',
	word varchar(60) NOT NULL default '',
	href varchar(60)	NOT NULL default '',
	type enum('text','image','article','link','poem','urllink','html') NOT NULL default 'image',
  PRIMARY KEY (link_id),
	KEY id (link_id)
) TYPE=MyISAM;
			EOS
		end
		def materials
			<<-EOS
CREATE TABLE materials ( 
  material_id int(6) unsigned NOT NULL auto_increment,
	name varchar(50) NOT NULL default '',
	PRIMARY KEY (material_id),
	KEY id (material_id,name)
) TYPE=MyISAM;
			EOS
		end
		def oneliner
			<<-EOS
CREATE TABLE oneliner ( 
  oneliner_id int(6) unsigned NOT NULL auto_increment,
	text text NOT NULL,
	location varchar(20) NOT NULL default 'hislife',
	color varchar(10) NOT NULL default '',
	size tinyint(3) unsigned NOT NULL default '18',
  active tinyint(1) unsigned NOT NULL default '1',
  PRIMARY KEY (oneliner_id),
  KEY id (oneliner_id,color,location,active)
) TYPE=MyISAM;
			EOS
		end
		def series
			<<-EOS
CREATE TABLE series ( 
	serie_id char(3) NOT NULL default 'AAA',
	name varchar(50) NOT NULL default '',
	PRIMARY KEY (serie_id),
	KEY id (serie_id,name)
) TYPE=MyISAM;
			EOS
		end
=begin
		def shop 
			<<-EOS
CREATE TABLE shop ( 
  shop_item_id int(6) unsigned NOT NULL auto_increment,
  artobject_id int(6) unsigned NULL,
	PRIMARY KEY (shop_item_id),
	KEY id (shop_item_id)
) TYPE=MyISAM;
			EOS
		end
		def slideshows
			<<-EOS
CREATE TABLE slideshows ( 
  slideshow_id int(6) unsigned NOT NULL auto_increment,
	type enum('rack','show','ticker') NOT NULL default 'show',
	title varchar(255) NOT NULL default '',
  PRIMARY KEY (slideshow_id),
	KEY id (slideshow_id)
) TYPE=MyISAM;
			EOS
		end
=end
		def slideshow_items
			<<-EOS
CREATE TABLE slideshow_items ( 
	slideshow_item_id int(6) unsigned NOT NULL auto_increment,
	slideshow varchar(255) NOT NULL default '',
  display_id int(10) unsigned NOT NULL,
	position varchar(60) NOT NULL default '',
	PRIMARY KEY (slideshow_item_id),
	KEY id (slideshow_item_id)
) TYPE=MyISAM;
			EOS
		end
		def tools
			<<-EOS
CREATE TABLE tools ( 
  tool_id int(6) unsigned NOT NULL auto_increment,
	name char(50) NOT NULL default '',
  PRIMARY KEY (tool_id),
	KEY id (tool_id,name)
) TYPE=MyISAM;
			EOS
		end
	end
	class MySQLObjects
		TABLES = [
			'artobjects', 'artgroups',
			'materials', 
			'oneliner', 'series', 'slideshow_items', 'tools',
			'countries', 'currencies', 'guestbook', 
			'displayelements', 'links',
			'artobjects_displayelements', 'links_displayelements',
			'displayelements_displayelements',
		]
		ARTGROUPS = {
			'MOV'	=>	[ 'Movies', 1 ],
			'PUB'	=>	[ 'Publications', 2 ],
			'POS'	=>	[ 'Posters', 3 ],
			'DES'	=>	[ 'Design', 4 ],
			'CAR'	=>	[ 'Carpet', 5 ],
			'DRA'	=>	[ 'Drawing', 6 ],
			'PHO'	=>	[ 'Photo', 7 ],
			'MUL'	=>	[ 'Multiple', 8 ],
			'PAI'	=>	[ 'Painting', 9 ],
			'SCH'	=>	[ 'Schnitzenthese', 10 ],
			'SCU'	=>	[ 'Sculpture', 11 ],
		}
		TABLES.each { |table|
			eval <<-EOS 
			def #{table}
				@#{table} ||= Array.new
			end
			EOS
		}
	end
	class GetMySQLData
		class MysqlIds
			def initialize
				@display = 0
				@link = 0
			end
			def add_display
				@display += 1
			end
			def display
				@display.to_s
			end
			def add_link
				@link += 1
			end
			def link
				@link.to_s
			end
		end
		class SlideShowItems < Array; end
		class SlideShowItem
			attr_accessor :slideshow, :slideshow_id, :artobject_id, :display_id, :artobject_title
		end
		class LinkTableItems < Array; end
		class LinkTableItem
			attr_accessor :text, :linked_to
			attr_accessor :src_dir, :src_file
			attr_accessor :link_id
			attr_accessor :type, :location
			attr_accessor :title, :author
			attr_accessor :display_id, :to_display_id
		end
		def initialize
			file = File.expand_path("../etc/db_connection_data.yml", File.dirname(__FILE__))
			data = YAML.load(File.read(file))
			host = 'localhost'
			old_db = 'davaz'
			new_db = 'davaz2'
			@old_mysql = Mysql.connect(host, data['user'], data['password'], old_db)
			@new_mysql = Mysql.connect(host, data['user'], data['password'], new_db)
		end
		def get_tables
			tables = @old_mysql.list_tables
		end
		def select_and_store_data_from_tables
			mysql_objects = MySQLObjects.new
			linktableitems = LinkTableItems.new
			slideshowitems = SlideShowItems.new
			ids = MysqlIds.new
			get_tables.each { |table_name|
				table = nil
				result = @old_mysql.query('select * from '+table_name)
				result.each_hash { |row|
					case table_name
					when /curriculumvitae/i
						table = Table::DisplayElement.new
						ids.add_display
						table.display_id = ids.display 
						table.type = 'biography'
						table.location = 'life_english'
						if(row['cv_year_till'] == '0000')
							table.title = row['cv_year']
						else
							table.title = row['cv_year'] + " - " + row['cv_year_till']
						end
						table.text = row['cv_text']
					when /curriculumpictures/i
						table = Table::Link.new
						table.display_id = row['cv_id']
						table.word = row['cv_pict_name']
						ids.add_link
						table.link_id = ids.link 
						unless(row['cv_pict_link'] == "")
							table.type = 'link'
							table.href = row['cv_pict_link']
						else
							table.type = 'image'
						end
						lti = LinkTableItem.new
						lti.type = 'image'
						lti.link_id = table.link_id
						lti.text = row['cv_pict_comment']
						lti.linked_to = :links
						lti.src_dir = 'images/upload/curriculum'
						lti.src_file = row['cv_pict_id']
						linktableitems.push(lti)
					when /country/i
						table = Table::Country.new
						table.country_id = row['contractions']
						table.name = row['countryName']
					when /material/i
						table = Table::Material.new
						table.id = row['idMaterial']
						table.name = row['material']
					when /oneline/i
						table = Table::OneLiner.new
						table.text = row['txt']
						table.location = row['location']
						table.color = row['color']
						table.size = row['size']
						table.active = row['aktive']
					when /serie/i
						table = Table::Serie.new
						table.serie_id = row['scode'] 
						table.name = row['serieName'] 
					when /slide$/i
						#table = Table::SlideShow.new
						#table.slideshow_id = row['idSlide']
						#table.type = row['type']
						#table.title = row['location']
					when /slidedata$/i
						item = SlideShowItem.new
						item.artobject_id = row['idArtObject']
						if(row['idSlide'] == '1')
							item.slideshow = 'family'
						elsif(row['idSlide'] == '11')
							item.slideshow = 'life'
						else
							item.slideshow = 'unknown'
						end
						slideshowitems.push(item)
					when /tool/i
						table = Table::Tool.new
						table.id = row['idTool']
						table.name = row['tool']
					when /catalogue/i
						comment = row['title']
						lti = LinkTableItem.new
						lti.link_id = row['idArtObject']
						case row['initial']	
						when /VID/i
							item = SlideShowItem.new
							item.slideshow = 'movies'
							item.artobject_id = row['idArtObject']
							item.artobject_title = row['title'] 
							slideshowitems.push(item)
							comment = [ row['title'], row['year'] ].join("\n")
							table = Table::ArtObject.new(row['idArtObject'])
							table.artgroup_id = 'MOV'
							table.price = '50' 
							case row['idMovieCategory']
							when /TRA/i
								table.type = 'trailor'
							when /ORI/i
								table.type = 'original'
							when /NONE/i
								table.type = 'none'
							else
								table.type = 'none'
							end
						else
							table = Table::ArtObject.new(row['idArtObject'])
							table.type = 'none'
						end
						table.artgroup_id = row['initial'] if table.artgroup_id.nil?
						table.artgroup_id = 'PHO' if (row['initial'] == 'FOT')
						table.tool_id = row['idTool']
						table.material_id = row['idMaterial']
						table.country_id = row['contractions']
						table.comment = row['comment']
						if(row['month']=='4' && row['day']=='31')
							row['day']='30'
						end
						if(row['month']=='0')
							month = '01'
						else
							month = row['month']
						end
						if(row['day']=='0')
							day = '01'
						else
							day = row['day']
						end
						table.date = ""+[row['year'], month, day ].join("-")+""
						table.serie_id = row['scode']
						table.serie_nr = row['serialNumber']
						table.size = row['size']
						table.location = row['location']
						table.language = row['language']
						table.title = enc2utf8(row['title'])
						lti.type = 'image'
						lti.title = comment 
						lti.linked_to = :artobjects
						lti.src_dir = 'images/upload/gallery'
						lti.src_file = row['idArtObject']
						linktableitems.push(lti)
						table.changeat = row['changeAt']
						table.public = row['public']
					end
					unless(table.nil?)
						mysql_objects.send(table.table_name).push(table)
					else
						#puts "table not found "+table_name
					end
				}
			}
			tables_from_xml_files(mysql_objects, ids, linktableitems)
			tables_from_yml_files(mysql_objects, ids, linktableitems)
			add_lectures(mysql_objects, ids, linktableitems)
			add_exhibitions(mysql_objects, ids, linktableitems)
			add_articles(mysql_objects, ids, linktableitems)
			add_biographies(mysql_objects, ids, linktableitems)
			add_passage_through_india(mysql_objects, ids)
			add_morphopolis_slideshow(mysql_objects, ids)
			{
				:mysql_objects	=>	mysql_objects,
				:linktableitems	=>	linktableitems,
				:slideshowitems	=>	slideshowitems,
			}
		end
=begin
		def create_shop_table(row, ids)
			table = Table::Shop.new
			ids.add_shop_item
			table.shop_item_id = ids.shop_item
			table.artobject_id = row['idArtObject']
			table.name = row['title']
			table.artgroup_id = 'MOV'
			#table.html = "<A href='http://davaz.hal/en/works/video_popup/#{table.artnumber}' name='detail infos' onClick=\"window.open('http://davaz.hal/en/works/video_popup/#{table.artnumber}/', 'Wunderblock A', 'menubar=no,resizable=yes,scrollbars=yes,height=700px,locationbar=no,toolbar=no,width=700px').focus(); return false\">#{row['title']}</A>"
			table
		end
=end
		def build_country_hash(mysql_objects)
			country_hash = Hash.new
			array = mysql_objects.send('countries')
			array.each { |country|
				country_hash.store(country.abbreviation, array.index(country)+1)
			}
			country_hash	
		end
		def build_serie_hash(mysql_objects)
			serie_hash = Hash.new
			array = mysql_objects.send('series')
			array.each { |serie|
				serie_hash.store(serie.abbreviation, array.index(serie)+1)
			}
			serie_hash	
		end
		def update_indices(mysql_objects)
			country_hash = build_country_hash(mysql_objects)
			serie_hash  = build_serie_hash(mysql_objects)
			mysql_objects.send('artobjects').each { |object|
				ctr_abbreviation = object.country_id		
				object.country_id = country_hash[ctr_abbreviation].to_s
				serie_abbreviation = object.serie_id
				object.serie_id = serie_hash[serie_abbreviation].to_s
			}
		end
		def start
			prepare_directories
			hash = select_and_store_data_from_tables
			#update_indices(mysql_objects)
			add_poems(hash[:linktableitems])
			MySQLObjects::TABLES.each { |table|
				#if(table=='displayelements')
					new = PrepareNewDatabase.new(@new_mysql)
					new.startquery(table)
					fill_up_objects = []
					hash[:mysql_objects].send(table).each { |object|
						if(object.respond_to?(:poem_links) && !object.poem_links.empty?)
							object.poem_links.each { |title, link_id|
								hash[:linktableitems].each { |lti|
									if(lti.title == title)		
										lti.link_id = link_id
									end
								}
							}
						end
						if((object.respond_to?(:display_id) && object.display_id.nil?) || (object.respond_to?(:link_id) && object.link_id=="0"))
							fill_up_objects.push(object)
						elsif(object.respond_to?(:price) && object.price != nil && object.respond_to?(:artgroup_id) && object.artgroup_id != 'MOV')
							query = [
								'INSERT INTO', table, 'VALUES', 
								'(', object.join_values, ');'
							].join(" ")
							@new_mysql.query(query)
							object.links.each { |lti|
								lti.link_id = @new_mysql.insert_id
								hash[:linktableitems].push(lti)
							}
						else
							query = [
								'INSERT INTO', table, 'VALUES', 
								'(', object.join_values, ');'
							].join(" ")
							@new_mysql.query(query)
						end
					}
					fill_up_objects.each { |object| 
						query = [
							'INSERT INTO', table, 'VALUES', 
							'(', object.join_values, ');'
						].join(" ")
						@new_mysql.query(query)
						if(object.respond_to?(:links) && !object.links.empty?)
							object.links.each { |lti|
								lti.display_id = @new_mysql.insert_id
								hash[:linktableitems].push(lti)
							}
						end
=begin
						object_id = @new_mysql.insert_id
						if(object.type='poem')
							link_id = nil
							hash[:mysql_objects].send('links').each { |obj| 
								link_id = obj.poem_links[object.title]
							}
							lnk = LinkTableItem.new
							lnk.link_id = link_id
							lnk.display_id = object_id
						end
=end
					}
				#end
			}
			handle_linktableitems(hash[:linktableitems])
			add_artgroups
			add_slideshows(hash[:mysql_objects], hash[:slideshowitems])
			add_currencies()
		end
		def add_currencies
			add_currency('CHF', 'USD', '0.815262')
			add_currency('CHF', 'EURO', '0.641383054')
		end
		def add_currency(origin, target, rate)
			query = <<-EOS
				INSERT INTO currencies
				VALUES ('#{origin}', '#{target}', '#{rate}')
			EOS
			@new_mysql.query(query)
		end
		def add_slideshows(mysql_objects, slideshowitems)
			#add_slideshow('life', '1', 'show')
			#add_slideshow('family', '2', 'show')
			#add_slideshow('movies', '4', 'ticker')
			items = slideshowitems.select { |item| item.slideshow == 'movies' }
			items.sort! { |x, y| x.artobject_title <=> y.artobject_title }
			items.reverse!
			add_slideshow_items(items, 'movies')
			items = slideshowitems.select { |item| item.slideshow == 'life' }
			add_slideshow_items(items, 'life')
			items = slideshowitems.select { |item| item.slideshow == 'family' }
			add_slideshow_items(items, 'family')
		end
		def add_slideshow(slideshow, slideshow_id, type)
			table = Table::SlideShow.new
			table.title = slideshow
			table.slideshow_id = slideshow_id
			table.type = type
			query = [
				'INSERT INTO slideshows VALUES',
				'(', table.join_values, ');'
			].join(" ")
			@new_mysql.query(query)
		end
		def add_slideshow_items(items, slideshow)
			position = 'A'
			items.each { |item| 
				table = Table::SlideShowItem.new
				table.slideshow = slideshow
				table.position = position.dup
				position.succ!
				result = @new_mysql.query("SELECT display_id FROM artobjects_displayelements WHERE artobject_id='#{item.artobject_id}'")
				result.each_hash { |key, value| 
					key.each { |col_name, col_value| 
						table.display_id = col_value
					}
				}
				query = [
					'INSERT INTO slideshow_items VALUES',
					'(', table.join_values, ');'
				].join(" ")
				@new_mysql.query(query)
			}
		end
		def prepare_directories
			upload_image_path = File.expand_path("../doc/resources/uploads/images", File.dirname(__FILE__))
			FileUtils.rm_rf(upload_image_path)
			FileUtils.mkdir(upload_image_path)
			(0..9).each { |i| 
				directory = upload_image_path + "/" + i.to_s
				FileUtils.mkdir(directory)
			}
		end
		def handle_linktableitems(linktableitems)
			linktableitems.each { |lti|
				unless(lti.linked_to==:articles)
					table = Table::DisplayElement.new
					if(lti.linked_to == :chinese_articles)
						table.text = lti.text
					else	
						table.text = Mysql.escape_string(lti.text) unless(lti.text.nil?)
					end
					table.type = lti.type unless(lti.type.nil?)
					table.location = lti.location unless(lti.location.nil?)
					table.title = lti.title unless (lti.title.nil?)
					table.author = lti.author unless (lti.author.nil?)
					query = [
						'INSERT INTO', table.table_name, 'VALUES', 
						'(', table.join_values, ');'
					].join(" ")
					@new_mysql.query(query)
					display_id = @new_mysql.insert_id
					if(lti.linked_to==:links && lti.type=='html')
						lti.display_id = display_id
					elsif(lti.linked_to==:displayelements)
						lti.to_display_id = display_id
					end
					link_id = lti.link_id
					if(lti.linked_to == :chinese_articles)
						lti.display_id = display_id 
					end
					if(lti.type == 'image')
						if(lti.src_dir.match(/gallery|curriculum/))
							image_path = File.expand_path("../../#{OLD_DAVAZ_DIR}/doc/#{lti.src_dir}/#{lti.src_file}", File.dirname(__FILE__)) 
						else
							image_path = File.expand_path("#{lti.src_dir}/#{lti.src_file}", File.dirname(__FILE__)) 
						end
						new_exension = nil
						extension = if(File.exist?(image_path + '.jpeg'))
							new_extension = '.jpg'
							'.jpeg'
						elsif(File.exist?(image_path + '.gif'))
							new_extension = '.gif'
							'.gif'
						elsif(File.exist?(image_path + '.jpg'))
							new_extension = '.jpg'
							'.jpg'
						else
							nil
						end
						if(image_path.match(/\.jpg$/))
							extension = ""
							new_extension = ".jpg"
						end
						new_path = File.expand_path("../doc/resources/uploads/images/#{display_id.to_s[-1,2]}/#{display_id}", File.dirname(__FILE__))
						unless(extension.nil?)
							old_image = image_path + extension
							new_image = new_path + new_extension 
							FileUtils.cp(old_image, new_image)
						else
							puts "no file found for #{image_path}" 
						end
					end
					#target_file = 
					#FileUtils.cp(src_file, target_file)
				end
				unless(lti.linked_to == :nowhere)
					unless(lti.display_id.nil? || lti.linked_to == :displayelements)
						display_id = lti.display_id
						link_id = lti.link_id
						lti.linked_to = :links
					end
					if(lti.linked_to == :displayelements)
						query = [
							"INSERT INTO #{lti.linked_to.to_s}_displayelements VALUES ('",
							lti.display_id, "','",
							lti.to_display_id,
							"');"
						].join()
					else
						query = [
							"INSERT INTO #{lti.linked_to.to_s}_displayelements VALUES ('",
							link_id.to_s, "','",
							display_id.to_s,
							"');"
						].join()
					end
					@new_mysql.query(query)
				end
			}
		end
		def add_passage_through_india(mysql_objects, ids)
			#table = Table::SlideShow.new
			#slideshow_id = "3"
			#table.slideshow_id = slideshow_id
			#table.title = 'passage_through_india'
			#table.type = 'ticker'
			#mysql_objects.send(table.table_name).push(table)
			files = ['fram3', 'fram4', 'fram5', 'fram6']
			images = []
			files.each { |filename|
				file = File.expand_path("../../#{OLD_DAVAZ_DIR}/doc/hislife/#{filename}.html", File.dirname(__FILE__))
				File.open(file) { |file|
					file.each { |line|
						if(match = line.match(/(scrolling_Pass\/)(\w+)(.gif)/))
							images.push(match[2])
						end
					}
				}
			}
			positions = {
				'one'					=>	'A',
				'three'				=>	'B',
				'four'				=>	'C',
				'six'					=>	'D',
				'eight'				=>	'E',
				'nine'				=>	'F',
				'ten'					=>	'G',
				'eleven'			=>	'H',
				'tweleve'			=>	'I',
				'thirteen'		=>	'J',
				'Fourteen'		=>	'K',
				'sixteen'			=>	'L',
				'seventeen'		=>	'M',
				'eightneen'		=>	'N',
				'nineteen'		=>	'O',
				'twenty'			=>	'P',
				'twentyone'		=>	'Q',
				'twentytwo'		=>	'R',
				'twenntythree'	=>	'S',
				'twentyfour'	=>	'T',
				'twentyfive'	=>	'U',
				'twentyeight'	=>	'V',
				'twentyfnine'	=>	'W',
				'thirty'			=>	'X',
				'thirtyone'		=>	'Y',
				'thirtytwo'		=>	'Z',
				'thirtythree'	=>	'ZA',
				'thirtyfour'	=>	'ZB',
			}
			images.each { |image|
				table = Table::DisplayElement.new
				ids.add_display
				table.display_id = ids.display 
				table.type = 'image'
				#table.location = 'india_ticker'
				table.text = image
				mysql_objects.send(table.table_name).push(table)
				old_image = File.expand_path("images/india_ticker/#{image}", File.dirname(__FILE__))
				extension = if(File.exist?(old_image + '.jpeg'))
					new_extension = '.jpg'
					'.jpeg'
				elsif(File.exist?(old_image + '.gif'))
					new_extension = '.gif'
					'.gif'
				elsif(File.exist?(old_image + '.jpg'))
					new_extension = '.jpg'
					'.jpg'
				else
					nil
				end
				new_image = File.expand_path("../doc/resources/uploads/images/#{table.display_id.to_s[-1,2]}/#{table.display_id}#{new_extension}", File.dirname(__FILE__))
				FileUtils.cp(old_image + extension, new_image)
				table = Table::SlideShowItem.new
				table.display_id = ids.display
				table.slideshow = 'passage_through_india'
				table.position = positions[image]
				mysql_objects.send(table.table_name).push(table)
			}
		end
		def add_morphopolis_slideshow(mysql_objects, ids)
			files = ['fram7', 'fram8', 'fram9', 'fram10']
			images = []
			files.each { |filename|
				file = File.expand_path("../../#{OLD_DAVAZ_DIR}/doc/hiswork/#{filename}.html", File.dirname(__FILE__))
				File.open(file) { |file|
					file.each { |line|
						if(match = line.match(/(morphopolis_scroll\/)(\w+)(.jpg)/))
							images.push(match[2])
						end
					}
				}
			}
			positions = {
				'MORPHOPOLIS01'					=>	'A',
				'MORPHOPOLIS02'					=>	'B',
				'MORPHOPOLIS03'					=>	'C',
				'MORPHOPOLIS04'					=>	'D',
				'MORPHOPOLIS05'					=>	'E',
				'MORPHOPOLIS06'					=>	'F',
				'MORPHOPOLIS07'					=>	'G',
				'MORPHOPOLIS08'					=>	'H',
				'MORPHOPOLIS09'					=>	'I',
				'MORPHOPOLIS11'					=>	'J',
				'MORPHOPOLIS12'					=>	'K',
				'MORPHOPOLIS13'					=>	'L',
				'MORPHOPOLIS14'					=>	'M',
				'MORPHOPOLIS15'					=>	'N',
				'MORPHOPOLIS16'					=>	'O',
				'MORPHOPOLIS17'					=>	'P',
				'MORPHOPOLIS18'					=>	'Q',
				'MORPHOPOLIS19'					=>	'R',
				'MORPHOPOLIS21'					=>	'S',
				'MORPHOPOLIS22'					=>	'T',
				'MORPHOPOLIS23'					=>	'U',
				'MORPHOPOLIS24'					=>	'V',
				'MORPHOPOLIS25'					=>	'W',
				'MORPHOPOLIS26'					=>	'X',
				'MORPHOPOLIS27'					=>	'Y',
				'MORPHOPOLIS28'					=>	'Z',
				'MORPHOPOLIS29'					=>	'ZA',
			}
			images.each { |image|
				table = Table::DisplayElement.new
				ids.add_display
				table.display_id = ids.display 
				table.type = 'image'
				table.text = image
				mysql_objects.send(table.table_name).push(table)
				old_image = File.expand_path("images/morphopolis/#{image}", File.dirname(__FILE__))
				extension = if(File.exist?(old_image + '.jpeg'))
					new_extension = '.jpg'
					'.jpeg'
				elsif(File.exist?(old_image + '.gif'))
					new_extension = '.gif'
					'.gif'
				elsif(File.exist?(old_image + '.jpg'))
					new_extension = '.jpg'
					'.jpg'
				else
					nil
				end
				new_image = File.expand_path("../doc/resources/uploads/images/#{table.display_id.to_s[-1,2]}/#{table.display_id}#{new_extension}", File.dirname(__FILE__))
				FileUtils.cp(old_image + extension, new_image)
				table = Table::SlideShowItem.new
				table.display_id = ids.display
				table.slideshow = 'morphopolis'
				table.position = positions[image]
				mysql_objects.send(table.table_name).push(table)
			}
		end
		def add_artgroups
			MySQLObjects::ARTGROUPS.each { |key, value| 
				sql = [
					"INSERT INTO artgroups VALUES (",
					"'#{key}','#{value.first}','#{value.last}');"
				].join
				@new_mysql.query(sql)
			}
		end
		def add_exhibitions(mysql_objects, ids, linktableitems)
			exhibitions = [
				{
					'title='	=>	'1966',	
					'text='		=>	'Gallery von Roten, Basel, Switzerland',	
				},
				{
					'title='	=>	'1968',	
					'text='		=>	'Gallery Gräber, Freiburg, Germany',	
				},
				{
					'title='	=>	'1969',	
					'position='	=>	'A',
					'text='		=>	'Stampa, Basel, Switzerland',	
				},
				{
					'title='	=>	'1969',	
					'position='	=>	'B',
					'text='		=>	'Fabrikausstellung, Stoll-Giroflex, Koblenz, Switzerland',	
				},
				{
					'title='	=>	'1970',	
					'text='		=>	'Gallery De Fries, Amsterdam, Holland',	
				},
				{
					'title='	=>	'1972',	
					'text='		=>	'Gallery Trudelhaus, Baden, Switzerland',
				},
				{
					'title='	=>	'1973',	
					'text='		=>	'Gallery Bettina, Zürich, Switzerland',	
				},
				{
					'title='	=>	'1979',	
					'text='		=>	'Rizzoli Gallery, Washington D.C., USA',	
				},
				{
					'title='	=>	'1991',	
					'text='		=>	'Gallery Bettina, Zürich, Switzerland',	
				},
				{
					'title='	=>	'1996',	
					'position='	=>	'A',
					'text='		=>	'State Opera, Red Salon, Budapest, Hungary',	
					:links		=>	{
						'Red Salon'	=>	[ 'red_salon' ]	
					},
				},
				{
					'title='	=>	'1996',	
					'position='	=>	'B',
					'text='		=>	'«Moving Focus», University of Economics und Sciences, Budapest, Hungary',	
				},
				{
					'title='	=>	'1996',	
					'position='	=>	'C',
					'text='		=>	'Béke Gallery, Budapest, Hungary',	
				},
				{
					'title='	=>	'1997',	
					'text='	=>	'Ecole Polytechnique Fédérale de Lausanne (EPFL), Lausanne, Switzerland',
					:links => {
						'EPFL'	=>	[ 'epfl' ]
					},
				},
				{
					'title='	=>	'1998',	
					'position='	=>	'A',
					'text='		=>	'«A semmi öröme - The Joy of Nothing», Kiscelli Museum, Budapest, Hungary',	
					:links => {
						'Kiscelli Museum'	=>	[ 'kiscelli_one', 'kiscelli_two', 'kiscelli_three', 'kiscelli_four', ]
					},
				},
				{
					'title='	=>	'1998',	
					'position='	=>	'B',
					'text='		=>	'«Wunderblock», Art Room Lengnau, Lengnau, Switzerland',	
				},
				{
					'title='	=>	'1999',	
					'position='	=>	'A',
					'text='		=>	'«Das Sägewerk in den Köpfen», Sagi 103, Illnau, Switzerland',	
				},
				{
					'title='	=>	'1999',	
					'position='	=>	'B',
					'text='		=>	'«Perspective», Mücsarnok / Kunsthalle, Budapest, Hungary',
				},
				{
					'title='	=>	'1999',	
					'position='	=>	'C',
					'text='		=>	'«Morpholis», Hall of Sculptures, Hangzhou, China',	
					:links	=>	{
						'Hall of Sculptures'	=>	[ 'morpho_ride_28' ],
					}
				},
				{
					'title='	=>	'2000',	
					'text='		=>	'«Space in Time», Chinese Painting Institute, Shanghai, China',	
					:links => {
						'Chinese Painting Institute'	=>	[ 'painting_institute_one', 'painting_institute_two', 'painting_institute_swf', ],
					},
				},
				{
					'title='	=>	'2001',	
					'text='		=>	'«Alice in Wonderland», Xintiandi Gallery, Shanghai, China',	
				},
			]
			write_mysql_objects(exhibitions, 'exhibition', mysql_objects, ids, linktableitems)
		end
		def add_articles(mysql_objects, ids, linktableitems)
			articles = [
				{
					'title='		=>	'Über die freien Schwingungen der künstlerischen Phantasie',
					'position='	=>	'A',	
					'author='			=>	'Prof. Josef Gantner, Kunsthistoriker, Basel',
					'text='			=>	enc2utf8(read_html_file('articles','schwingungen')),
					#:links			=>	{ 'Über die freien Schwingungen der künstlerischen Phantasie' => '', },
				},
				{
					'title='		=>	'"Das Bild, das sich von selbst malt"',
					'position='	=>	'B',
					'author='			=>	'Interview mit Erzsebet Issekutz, ELITE Magazin, Budapest',
					'text='			=>	enc2utf8(read_html_file('articles','bild')),
					#:links			=>	{ '"Das Bild, das sich von selbst malt"' => '', },
				},
				{
					'title='		=>	'Eine Interpretation',
					'position='	=>	'C',
					'author='			=>	'Wolfgang Jacobi, Architekt, Nebikon',
					'text='			=>	enc2utf8(read_html_file('articles','interpretation')),
					#:links			=>	{ 'Eine Interpretation' => '', },
				},
				{
					'title='		=>	'Man kann keinen Sprung machen und sich dabei "beobachten"',
					'position='	=>	'D',
					'author='			=>	'Roy Oppenheim, Kunsthistoriker, Bern',
					'text='			=>	enc2utf8(read_html_file('articles','sprung')),
					#:links			=>	{ 'Man kann keinen Sprung machen und sich dabei "beobachten"' => '', },
				},
				{
					'title='		=>	'Kunst und Evolution',
					'position='	=>	'E',
					'author='			=>	'Dr. med. Ursula Davatz, Washington, D.C., USA',
					'text='			=>	enc2utf8(read_html_file('articles','kunst')),
					#:links			=>	{ 'Kunst und Evolution' => '', },
				},
				{
					'title='		=>	'Abstrakte Virtualität',
					'position='	=>	'F',
					'author='			=>	'Dr. med. Ursula Davatz, Zürich',
					'text='			=>	enc2utf8(read_html_file('articles','virtualitaet')),
					#:links			=>	{ 'Abstrakte Virtualität' => '', },
				},
				{
					'title='		=>	'El Laberinto Sentimental',
					'position='	=>	'G',
					'author='			=>	'Dr. med. Ursula Davatz, Zürich',
					'text='			=>	enc2utf8(read_html_file('articles','laberinto')),
					#:links			=>	{ 'El Laberinto Sentimental' => '', },
				},
				{
					'title='		=>	'A New Formatting of perception',
					'position='	=>	'H',
					'author='			=>	'Dr. med. Ursula Davatz, Zürich',
					'text='			=>	enc2utf8(read_html_file('articles','perception')),
					#:links			=>	{ 'A New Formatting of perception' => '', },
				},
				{
					'title='		=>	'Da Vaz - The Inventor of American Baroque',
					'position='	=>	'I',
					'author='			=>	'Roy Oppenheim, Kunsthistoriker, Bern',
					'text='			=>	enc2utf8(read_html_file('articles','baroque')),
				#	:links			=>	{ 
				#		'Da Vaz - The Inventor of American Baroque'	=> '', 
				#		'Chinese'	=>	enc2utf8(read_html_file('articles','baroque_chinese')),
				#	},
				},
				{
					'title='		=>	'Da Vaz - The Inventor of American Baroque in Chinese',
					'position='	=>	'J',
					'author='			=>	'Roy Oppenheim, Kunsthistoriker, Bern',
					'text='			=>	enc2utf8(read_html_file('articles','baroque_chinese')),
=begin
					:links			=>	{ 
						'Da Vaz - The Inventor of American Baroque'	=> '', 
						'Chinese'	=>	enc2utf8(read_html_file('articles','baroque_chinese')),
					},
=end
				},
				{
					'title='		=>	'A Script of Space',
					'position='	=>	'K',
					'author='			=>	'Marie-Theres Stauffer',
					'text='			=>	enc2utf8(read_html_file('articles','space')),
					#:links			=>	{ 'A Script of Space' => '', },
				},
				{
					'title='		=>	'Raising China, a creative Documentary',
					'position='	=>	'L',
					'author='			=>	'Interview: András Péterffy - Jürg Da Vaz',
					'text='			=>	enc2utf8(read_html_file('articles','china')),
					#:links			=>	{ 'Raising China, a creative Documentary' => '', },
				},
				{
					'title='		=>	'His Life - His Work - His Ideas in Chinese',
					'position='	=>	'M',
					'author='			=>	'Jiang Ming Song, VP China National Academy of Fine Arts',
					'text='			=>	read_html_file('articles','hislife_chinese'),
					'charset='	=>	'GB2312',
					#:links			=>	{ 'Chinese' => },
				},
			]
			articles.each { |hsh|
				hsh.store('type=', 'html')
				hsh.store('location=', 'articles')
			}
			write_mysql_objects(articles, 'article', mysql_objects, ids, linktableitems)
		end
		def add_biographies(mysql_objects, ids, linktableitems)
			biographies = [
				{
					'title='	=>	'cv_chinese',
					'text='		=>	read_html_file('hislife', 'cv_chinese'),
					'type='		=>	'html',
				},
				{
					'title='	=>	'cv_hungarian',
					'text='		=>	read_html_file('hislife', 'cv_hungarian'),
					'type='		=>	'html',
				},
=begin
				{
					'title='	=>	'Russian Biography',
					'text='		=>	parse_pdf('hislife', 'cv_russian'),
					'type='		=>	'html',
					'location='	=>	'life',
				},
=end
			]
			#write_mysql_objects(biographies, 'html', mysql_objects, ids, linktableitems)
			parsing = ParseCVHtml::Parsing.new('cv_hungarian')
			parsing.start.each { |entry| 
				table = Table::DisplayElement.new
				table.location = 'life_hungarian'	
				table.title = entry.year
				table.text = enc2utf8(entry.text)
				mysql_objects.send(table.table_name).push(table)
			}
			parsing = ParseCVHtml::Parsing.new('cv_chinese')
			parsing.start.each { |entry| 
				table = Table::DisplayElement.new
				table.location = 'life_chinese'	
				table.title = entry.year
				table.text = enc2utf8(entry.text)
				if(entry.year=='1999')
				end
				mysql_objects.send(table.table_name).push(table)
			}
		end
		def read_html_file(dir, file)
			content = ""
			html_file = File.expand_path("html/#{dir}/#{file}.html", File.dirname(__FILE__))
			File.open(html_file) { |html|
				html.each { |line|
					if(file=='cv_hungarian' || file=='cv_chinese')
						content << enc2utf8(line)
					else
						content << line
					end
				}
			}
			content
		end
		def add_lectures(mysql_objects, ids, linktableitems)
			lectures = [
				{
					'title='	=> '1998',
					'text='		=> '«Creative Documentary», Catholic University, Budapest, Hungary',
				},
				{
					'title='	=>	'1999',
					'text='		=>	'«Abstract Drawing», China National Academy of Fine Arts, Hangshou, China',
				},
				{
					'title='	=>	'2000',
					'position='	=>	'A',
					'text='		=>	'«Viewing is acting», Eötvös Lorànd University, Budapest, Hungary',
				},
				{
					'title='	=>	'2000',
					'position='	=>	'B',
					'text='		=>	'«Ouvrir les Yeux», Seminar, Shanghai Institute of Design, China',
					:links	=>	{
						'Ouvrir les Yeux'	=>	[ 'students_one', 'students_two', 'students_three', 'students_four' ],
					},
				},
				{
					'title='	=>	'2000',
					'position='	=>	'C',
					'text='		=>	'«Morphopolis», Seminar on visualization, Hochschule Rapperswil, Switzerland',
					:links	=>	{
						'html_morpho'		=>	[ '«Morphopolis»', 'lectures', 'Morphopolis' ],
						'html_visu'		=>	[ 'visualization', 'lectures', 'visualization' ],
					},
				},
				{
					'title='	=>	'2001',
					'position='	=>	'A',
					'text='		=>	'«Immer wieder fragen...», Seminar, Gymnasium am Münsterplatz, Basel, Switzerland',
				},
				{
					'title='	=>	'2001',
					'position='	=>	'B',
					'text='		=>	'«Gespannt», Seminar, Hochschule Rapperswil, Switzerland',
				},
				{
					'title='	=>	'2001',
					'position='	=>	'C',
					'text='		=>	'«PublicSpace», Werkstattbericht, International Design Forum (JIPAT) Tokyo, Japan',
					:links	=>	{
						'html_public'	=>	[ '«PublicSpace»', 'lectures', 'public_space' ],
					},
				},
				{
					'title='	=>	'2001',
					'position='	=>	'D',
					'text='		=>	'«Dialogische - Vermischungen», Werkstattbericht, Muthesius-Hochschule, Kiel, Germany',
				},
				{
					'title='	=>	'2001',
					'position='	=>	'E',
					'text='		=>	'«City-Art-Scape», Werkstattbericht, Fachhochschule Nürtingen, Germany',
				},
			]
			write_mysql_objects(lectures, 'lecture', mysql_objects, ids, linktableitems)
		end
		def write_mysql_objects(objects, site, mysql_objects, ids, linktableitems)
			imgs = [ 
				'students_one', 'students_two', 'students_three', 'students_four', 
			]
			image_comments = {
				'red_salon'	=>	'Red Salon',	
				'epfl'			=>	'Exhibition moving focus,<br>EPFL Lausanne, 1997',
				'kiscelli_one'	=>	'Kiscelli Museum 1998,<br>exhibition �The Joy of Nothing�',
				'kiscelli_two'	=>	'Acryl on canvas, computer assisted,<br>300 x 1000 cm',
				'kiscelli_three'	=>	'�Wenn die Bananen schweigen, h�rt man<br>in der Ferne fast die Berge� Acryl on canvas,<br>computer assisted, 300 x 1000 cm',
				'kiscelli_four'	=>	'�Varanasi Group�<br>Acryl on canvas, computer assisted,<br>300 x 1000 cm',
				'painting_institute_one'	=>	'Chinese Painting Institute 1, 2000',
				'painting_institute_two'	=>	'Chinese Painting Institute 2, 2000',
			}
			objects.each { |object| 
				table = Table::DisplayElement.new
				ids.add_display
				table.display_id = ids.display
				table.type = site
				table.location = site + 's' unless site=='html'
				object.each { |key, value| 
					unless(key==:links)
						table.send(key, value)	
					end
				}
				object.each { |key, value| 
					if(key==:links)
						value.each { |word, links| 
							if (word == 'html_public')
								element = Table::DisplayElement.new	
								ids.add_display
								element.display_id = ids.display
								element.type = 'text'
								element.title = 'PublicSpace'
								element.author = enc2utf8("by J�rg Da Vaz\nmultimedia artist")
								str = <<-EOS
								The �Forum� in the Roman Empire, the �Marktplatz� of German Cities or the �Piazzas� in Italy are birthplaces of PublicSpace - nodal points in the fabric of society for people to move, exchange and relax.

								PublicSpace has the important mandate to facilitate the structuring of new habitats and niches for people.It is a forum for visual and political dialogue as well. As a generator of attitude and lifestyle it offers changing concepts for the wellbeing of man in a globalized world. It promotes individual commitment and passion and acts at the same time as a distributor for personal taste to larger networks and communities.
								EOS
								element.text = enc2utf8(str)
								lnk = Table::Link.new
								ids.add_link
								lnk.link_id = ids.link
								lnk.type = 'text'
								lnk.display_id = table.display_id 
								lnk.word = '«PublicSpace»'
								lti = LinkTableItem.new
								lti.link_id = lnk.link_id
								lti.display_id = element.display_id
								lti.linked_to = :links
								linktableitems.push(lti)
								mysql_objects.send(element.table_name).push(element)
								mysql_objects.send(lnk.table_name).push(lnk)
							elsif (word == 'html_visu')
								element = Table::DisplayElement.new	
								ids.add_display
								element.display_id = ids.display
								element.type = 'html'
								str = <<-EOS
<table align="center">
  <tr>
	<td> <applet name="ptviewer" valign=bottom border=0 hspace=0 vspace=0 archive="/resources/java/ptviewer.jar" code=ptviewer.class width="380" height="200" mayscript=true>
        <param name=file 		value="ptviewer:0">
				<param name=frame		value="/resources/images/global/control.gif">
        <param name=bar_x 		value="198">
        <param name=bar_y 		value="163">
        <param name=bar_width 	value="165">
        <param name=bar_height 	value="23">
        <param name=inits		value="ptviewer:startApplet(1)">
        <param name=shotspot0   value=" x310 y186 a324 b200 u'ptviewer:startAutoPan(0.5,0,1)' ">
        <param name=shotspot1   value=" x324 y186 a338 b200 u'ptviewer:stopAutoPan()' ">
        <param name=shotspot2   value=" x338 y186 a352 b200 u'ptviewer:startAutoPan(0,0,0.97)' ">
        <param name=shotspot3   value=" x352 y186 a366 b200 u'ptviewer:startAutoPan(0,0,1.03)' ">
        <param name=shotspot4   value=" x366 y186 a380 b200 u'ptviewer:gotoView(0,0,80)' ">
				<param name=pano0		value=" {file=/resources/images/html/32_MorphoRidePict.jpg}
												    {pan=-45}
												    {tilt=-50}
												    {fov=120}
												    {fovmax=120}
												    {fovmin=30}
												    {auto=0.5}
												    {mousehs=mousehs}
												    {getview=getview} ">
														<param name=wait		value="/resources/images/html/32_MorphoRidePict.jpg">
      </applet>
</td>
  </tr>
  <tr align="left" valign="top"> 
    <td> 
      <p>Visualisation</p>
	</td>
  </tr>
</table>
								EOS
								element.text = enc2utf8(str)
								lnk = Table::Link.new
								ids.add_link
								lnk.link_id = ids.link
								lnk.type = 'text'
								lnk.display_id = table.display_id 
								lnk.word = 'visualization'
								lti = LinkTableItem.new
								lti.link_id = lnk.link_id
								lti.display_id = element.display_id
								lti.linked_to = :links
								linktableitems.push(lti)
								mysql_objects.send(element.table_name).push(element)
								mysql_objects.send(lnk.table_name).push(lnk)
							elsif (word == 'html_morpho')
								element = Table::DisplayElement.new	
								ids.add_display
								element.display_id = ids.display
								element.type = 'html'
								str = <<-EOS
								<table align="center" width="532" height="237">
								  <tr> 
								    <td colspan="3"><img src="/resources/images/html/morphopolis.jpg" width="580" height="180" alt=""></td>
								  </tr>
								  <tr> 
								    <td colspan="3" valign="top" nowrap> 
											<p><a href="http://www.apple.com/quicktime/download/"><img src="/resources/images/html/quicktime.gif" width="40" height="47" border="0" align="right" alt=""></a><a href="/resources/movies/html/morphopolis.mov">QuickTime 
								        &laquo;Morphopolis&raquo; 24KB, Seminar, Hochschule Rapperswil</a></p>
								      </td>
								  </tr>
								</table
								EOS
								element.text = enc2utf8(str)
								lnk = Table::Link.new
								ids.add_link
								lnk.link_id = ids.link
								lnk.type = 'text'
								lnk.display_id = table.display_id 
								lnk.word = '«Morphopolis»'
								lti = LinkTableItem.new
								lti.link_id = lnk.link_id
								lti.display_id = element.display_id
								lti.linked_to = :links
								linktableitems.push(lti)
								mysql_objects.send(element.table_name).push(element)
								mysql_objects.send(lnk.table_name).push(lnk)
							else
								lnk = Table::Link.new
								ids.add_link
								lnk.link_id = ids.link
								lnk.display_id = ids.display
								lnk.word = word
								if(site=='article')	
									lnk.type = 'article'
									lti = LinkTableItem.new
									lti.link_id = lnk.link_id
									if(word=='Chinese')
										lti.linked_to = :chinese_articles
										lti.text = links 
										lti.type = 'chinese_article'
										#lti.type = object['type='] 
										#lti.location = 'articles' 
									else
										lti.linked_to = :articles
										lti.display_id = table.display_id
									end
									linktableitems.push(lti)
								elsif(word.match(/^html_/))
									lnk.type = 'html'
									file = links.pop	
									dir = links.pop
									word = links.pop
									lnk.word = word 
									lti = LinkTableItem.new
									lti.type = 'html'
									lti.link_id = lnk.link_id
									lti.linked_to = :links
									lti.text = enc2utf8(read_html_file(dir, file))
									linktableitems.push(lti)
								else
									lnk.type = 'image'
									links.each { |link|
										lti = LinkTableItem.new
										lti.type = 'image'
										lti.link_id = lnk.link_id
										lti.src_dir = "images/artobjects/#{site}s"
										lti.src_file = link
										lti.linked_to = :links
										lti.text = image_comments[link]
										linktableitems.push(lti)
									}
								end
								mysql_objects.send(lnk.table_name).push(lnk)
							end
						}
					end
				}
				mysql_objects.send(table.table_name).push(table)
			}
		end
		def create_blocks_from_html(html_text, mysql_objects, site, ids)
			html_text.each { |text| 
				table = Table::DisplayElement.new
				ids.add_display
				table.display_id = ids.display
				table.title = text.first 
				table.text = text.last 
				table.type = 'publicspace'
				mysql_objects.send(table.table_name).push(table)
			}
		end
		def add_poems(linktableitems)
			table = LinkTableItem.new
			table.type = 'poem'
			table.title = 'Power'
			table.text = "The question of reason\nis in fact a question of table,\na question of control\nof what is not yet configured\nin your mind."
			table.author = 'Da Vaz'
			table.linked_to = 'links' 
			linktableitems.push(table)
			table = LinkTableItem.new
			table.type = 'poem'
			table.title = 'Bottleneck'
			table.text = "While time never suffices to judge each stroke by the bundles of lines I have effectively created, before arriving at the decision as to how the journey is to continue, this table actually makes it possible to develop certain white wholes during the work process to defer choices, to thus compress the process underway and at the same time to make it predisposed to change in the stroke direction, to deviations that invoke the unexpected."
			table.author = 'Da Vaz'
			table.linked_to = 'links' 
			linktableitems.push(table)
			table = LinkTableItem.new
			table.type = 'poem'
			table.title = 'My Heartbeat'
			table.text = 'My Heartbeat is my family'
			table.author = 'Da Vaz'
			table.linked_to = 'links' 
			linktableitems.push(table)
			table = LinkTableItem.new
			table.type = 'poem'
			table.title = 'Hunting'
			table.text = ' To catch and display processes that have no pre-existence.'
			table.author = 'Da Vaz'
			table.linked_to = 'links' 
			linktableitems.push(table)
			table = LinkTableItem.new
			table.type = 'poem'
			table.title = 'Imagination'
			table.text = 'The creative mind is like a room full of players, where many attempts are being made at the same time and multiple processes of parallel moves are superimposed on the first one. While each move defines its own direction, string based conceptual structures far larger and more complex evolve into multiplying variations. This pooling of inconsequential chance-phenomena may lead to new forms of visual essence.'
			table.author = 'Da Vaz'
			table.linked_to = 'links' 
			linktableitems.push(table)
			table = LinkTableItem.new
			table.type = 'poem'
			table.title = 'Journey'
			table.text = 'It is like travelling in earlier times: the routes were arduous, and perhaps there were awkward moments to endure, which turned the venture into an adventure. The duration of the table by itself made sure that the yearning for distant places remained.'
			table.author = 'Da Vaz'
			table.linked_to = 'links' 
			linktableitems.push(table)
		end
		def tables_from_xml_files(mysql_objects, ids,linktableitems)
			xml = XML.new(mysql_objects, ids, linktableitems)
			xml.get_news_tables
			xml.get_guestbook_tables
			xml.get_link_tables
			xml.get_shop_tables
		end
		def tables_from_yml_files(mysql_objects, ids, linktableitems) 
			comments = {
				:barbara_tabitha	=>	'Heimatschein Barbara Tabitha',
				:politicians			=>	'Dekan Johannes Davatz, 1630 - 1711<br>Fanas 1690',
				:administrators		=>	'Zinsbriefsiegel: Hans Dafacz, 1638',
				:teachers					=>	'Teachers',
				:judges						=>	'Great Grandfather Georg Davatz, 1893',
				:women						=>	'When a man loves a Woman, 1973',
				:kranidi					=>	'Kranidi, 26.11.94',
				:drama						=>	'H u n t i n g to catch and display processes that have no pre-existence.<br><br>Da Vaz',
				:script						=>	'Script',
				:cannotread				=>	'"I can not read but draw"<br><br>Da Vaz',
				:morgen						=>	'M o r g e n w&uuml;rde ich es mir anders &uuml;berlegen<br>- unter Umst&auml;nden -<br><br>Da Vaz',
				:perceive					=>	'&laquo;The viewer ought to encounter both: the external fact of the object and his inner emotional state. Creativity, Da Vaz says, is intensely personal.&raquo;',
				:ariuscha					=>	'Ariuscha-Madlaina-Barbulin Davatz',
				:zeno							=>	'Zeno with installation, 1982',
				:fay							=>	'Fay and Ariuscha with dolls, Washington D.C., 1979 ',
				:woody						=>	'Woody',
				:playing					=>	'Fay and Ariuscha, Rigistrasse 4, Z&uuml;rich ',
				:opabinia					=>	'My beloved Opabinia',
				:luesai						=>	'L&uuml;sai, Reportage "Sch&ouml;ner Wohnen" February 1985',
				:america					=>	'Gruss aus dem St.Ant&ouml;nien-Thale!<br><br>abgeschickt: Z&uuml;rich-Unterstrass, 11.2.1899<br>angekommen: New York, 21.2.1899<br><br>An Mr. John. Davatz<br>726 Cleveland Str.<br>Haughville<br>Indianapolis<br>Indiana, USA<br><br>Meine Lieben,<br>....',
				:brasil						=>	'Die Familie Thomas Davatz-Auer,<br>aufgenommen ca. 1865<br><br>hintere Reihe: Margaretha, Luzia, Barbara-Tabitha<br>Mitte: Vater Thomas, Elsbeth, Christian<br>Vorn: Jakob, Mutter Katharina mit Thomas, Ursula, Hans-Peter',
			}
			yml_dir = File.expand_path('data/lnf/en', \
				File.dirname(__FILE__))
			files = {
				'hisfamily_intro.yml'				=>	'hisfamily',
				'hisinspiration_intro.yml'	=>	'hisinspiration',
				'hiswork_intro.yml'					=>	'hiswork',
				'the_family.yml'						=>	'thefamily',
			}
			files.each { |filename, site|
				hsh = YAML.load(File.read(File.join(yml_dir, filename))).ivars
				lines = []
				element_links = {} 
				unless(hsh['links'].nil?)
					hsh['links'].each { |links|
						word = links.first
						key = links[1].last
						href = links[1].join("/")
						table = Table::Link.new
						table.word = word
						ids.add_link
						table.link_id = ids.link
						lti = LinkTableItem.new
						lti.type = 'image'
						lti.link_id = table.link_id
						lti.text = comments[key]
						lti.src_dir = 'images/tooltip'
						lti.src_file = key
						lti.linked_to = :links
						linktableitems.push(lti)
						table.type = 'image'
						element_links.store(table.word, table)
					}
				end
				table = Table::DisplayElement.new 
				position = "A"
				ids.add_display
				table.display_id = ids.display 
				table.location = site
				table.position = position.dup 
				hsh['lines'].each { |line|
					if(line.nil?)
						table.text = lines.join("\n")
						mysql_objects.send(table.table_name).push(table)
						table = Table::DisplayElement.new 
						ids.add_display
						position.succ!
						table.display_id = ids.display
						table.location = site
						table.position = position.dup
						lines = []
					else
						lines << line	
						element_links.each { |word, link_table|
							if(line.match(/#{word}/))
								link_table.display_id = ids.display
								mysql_objects.send(link_table.table_name).push(link_table)
							end
						}
					end
				}
				table.text = lines.join("\n")
				mysql_objects.send(table.table_name).push(table)
			}
			poem_titles = [ 'Power', 'My Heartbeat', 'Bottleneck', 'Hunting', 'Imagination', 'Journey' ]
			table = Table::DisplayElement.new
			table.position = 'B'
			table.location = 'hisinspiration'
			ids.add_display
			table.display_id = ids.display
			table.text = poem_titles.join(" | ")
			table.type = 'poems'
			poem_titles.each { |title| 
				link = Table::Link.new
				ids.add_link
				link.link_id = ids.link
				link.poem_links.store(title, link.link_id)
				link.word = title
				link.display_id = ids.display
				link.type = 'poem'
				mysql_objects.send(link.table_name).push(link)
			}
			mysql_objects.send(table.table_name).push(table)
			lti = LinkTableItem.new
			lti.type = 'image'
			lti.text = comments[:barbara_tabitha]
			lti.src_dir = 'images/tooltip'
			lti.src_file = :barbara_tabitha
			lti.linked_to = :nowhere
			linktableitems.push(lti)
		end
		def enc2utf8(string)
			Iconv.iconv('utf8', 'latin1', string).first
		end
		def enc(string)
			#Iconv.iconv('latin1', 'utf8', string).first
			#Iconv.iconv('utf8', 'latin1', string).first
		end
	end
end

DavazMySQL::GetMySQLData.new.start
