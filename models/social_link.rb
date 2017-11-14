class SocialLink < ActiveRecord::Base
  belongs_to :library

  default_scope { order(:position) }

  NETWORKS = [
    { name: 'Blog',                     code: 'blog',        link_title: 'Our blog' },
    { name: 'Blog (Blogger/Blogspot)',  code: 'blogger',     link_title: 'Our Blogspot blog', short_name: 'Blog' },
    { name: 'Blog (Wordpress)',         code: 'wordpress',   link_title: 'Our Wordpress blog', short_name: 'Blog' },
    { name: 'Delicious',                code: 'delicious',   url_prefix: 'https://del.icio.us/' },
    { name: 'Facebook',                 code: 'facebook',    link_title: 'Follow us on Facebook' },
    { name: 'Flickr',                   code: 'flickr' },
    { name: 'FourSquare',               code: 'foursquare',  link_title: 'Check in on FourSquare' },
    { name: 'GoodReads',                code: 'goodreads' },
    { name: 'Google+',                  code: 'google-plus' },
    { name: 'Instagram',                code: 'instagram' },
    { name: 'LibGuides',                code: 'libguides',   link_title: 'Find us on LibGuides' },
    { name: 'LibraryThing',             code: 'librarything' },
    { name: 'LinkedIn',                 code: 'linkedin' },
    { name: 'MySpace',                  code: 'myspace' },
    { name: 'Netvibes',                 code: 'netvibes' },
    { name: 'Photobucket',              code: 'photobucket' },
    { name: 'Picasa',                   code: 'picasa' },
    { name: 'Pinterest',                code: 'pinterest',   url_prefix: 'http://www.pinterest.com/' },
    { name: 'RSS',                      code: 'rss' },
    { name: 'Slideshare',               code: 'slideshare' },
    { name: 'SoundCloud',               code: 'soundcloud' },
    { name: 'Tumblr',                   code: 'tumblr',      url_prefix: 'http//', url_suffix: '.tumblr.com/' },
    { name: 'Twitter',                  code: 'twitter',     url_prefix: 'https//twitter.com/',        username_prefix: '@' },
    { name: 'Vimeo',                    code: 'vimeo' },
    { name: 'Wikipedia',                code: 'wikipedia' },
    { name: 'WorldCat',                 code: 'worldcat' },
    { name: 'YouTube',                  code: 'youtube',     url_prefix: 'http://www.youtube.com/' }
  ]

  # Returns a URL, even if the 'url' field contains a username,
  # by intelligently handling usernames
  def auto_url
    return self.url if self.url =~ /^https?:\/\//
    if network_info = NETWORKS.select{|n| n[:code] == self.network}.first
      "#{network_info[:url_prefix]}#{self.url}#{network_info[:url_suffix]}"
    else
      self.url
    end
  end

  # Returns a complete link tag as HTML
  def auto_link(content = nil, attributes = {}, use_short_name = false)
    return "<!-- network_info not found in auto_link(#{self.network}) -->" unless network_info = NETWORKS.select{|n| n[:code] == self.network}.first
    content ||= (use_short_name ? (network_info[:short_name] || network_info[:name]) : network_info[:name])
    attributes = attributes.with_indifferent_access
    attributes[:class] = (attributes[:class] || '') + " #{network_info[:code]}"
    attributes[:title] ||= (network_info[:link_title] || "Our #{network_info[:name]} page")
    attributes[:href] = self.auto_url
    atts = attributes.collect{|k,v| " #{k}=\"#{v.strip}\""}.join
    "<a#{atts}>#{content.strip}</a>"
  end
end
