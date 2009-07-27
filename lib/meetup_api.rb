require 'net/http'
require 'rubygems'
require 'json'

module MeetupApi
  DEV = ''
  API_BASE_URL = "http://api#{DEV}.meetup.com/"
  EVENTS_URI = 'events'
  RSVPS_URI = 'rsvps'
  MEMBERS_URI = 'members'
  GROUPS_URI = 'groups'
  PHOTOS_URI = 'photos'
  TOPICS_URI = 'topics'
  COMMENTS_URI = 'comments'
  
  class Client
    attr_reader :config
    def initialize(config)
      @config = config
    end
    
    def get_events(args)
      args['after'] ||= '01012000'
      ApiResponse.new(fetch(EVENTS_URI, args), Event, self)
    end

    def get_rsvps(args)
      ApiResponse.new(fetch(RSVPS_URI, args), Rsvp, self)
    end
    
    def get_members(args)
      ApiResponse.new(fetch(MEMBERS_URI, args), Member, self)
    end
    
    def get_groups(args)
      ApiResponse.new(fetch(GROUPS_URI, args), Group, self)
    end
    
    def get_photos(args)
      ApiResponse.new(fetch(PHOTOS_URI, args), Photo, self)
    end
    
    def get_topics(args)
      ApiResponse.new(fetch(TOPICS_URI, args), Topic, self)
    end
    
    def get_comments(args)
      ApiResponse.new(fetch(COMMENTS_URI, args), Comment, self)
    end

    def fetch(uri, url_args={})
      url_args['format'] = 'json'
      url_args['key'] = @config[:key] if @config[:key]
      args = URI.escape(url_args.collect{|k,v| "#{k}=#{v}"}.join('&'))
      url = "#{API_BASE_URL}#{uri}/?#{args}"
      data = Net::HTTP.get_response(URI.parse(url)).body
      
      # ugh - rate limit error throws badly formed JSON
      begin
        JSON.parse(data)
      rescue Exception => e
        raise BaseException(e)
      end
    end
  end

  class ApiResponse
    include Enumerable
    attr_reader :meta, :results

    def initialize(json, klass, api)
      if (meta_data = json['meta'])
        @meta = meta_data
        @results = json['results'].collect {|hash| klass.new(hash, api)}
        
      else
        raise ClientException.new(json)
      end
    end
    
    def [](i)
      @results[i]
    end
    
    def each
      @results.each { |item| yield item }
    end
    
    def count
      @results.count
    end
  end
  
  # Turns a hash into an object - see http://tinyurl.com/97dtjj
  class Hashit
    def initialize(hash, client)
      # Pass the client into the ApiItem so scoped calls can be made ex: events.rsvps
      @client = client
      hash.each do |k,v|
        # create and initialize an instance variable for this key/value pair
        self.instance_variable_set("@#{k}", v)
        # create the getter that returns the instance variable
        self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
        # create the setter that sets the instance variable (disabled for readonly)
        ##self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
      end
    end
  end
  
  # Base class for an item in a result set returned by the API.
  class ApiItem < Hashit
  end
  
  class Event < ApiItem
    def rsvps(extraparams={})
      extraparams['event_id'] = self.id
      @client.get_rsvps extraparams
    end
    
    def to_s
      "Event #{self.id} named #{self.name} at #{self.time} (url: #{self.event_url})"
    end
  end
  
  class Rsvp < ApiItem
    def to_s
      "Rsvp by #{self.name} (#{self.link}) with comment: #{self.comment}"
    end
  end
  
  class Group < ApiItem
    def group_members(extraparams={})
      extraparams['group_id'] = self.id
      @client.get_members extraparams
    end
    
    def photos(extraparams={})
      extraparams['group_id'] = self.id
      @client.get_photos extraparams
    end
    
    def comments(extraparams={})
      extraparams['group_id'] = self.id
      @client.get_comments extraparams
    end
    
    def events(extraparams={})
      extraparams['group_id'] = self.id
      @client.get_events extraparams
    end
    
    def to_s
      "Group #{self.id} named #{self.name}"
    end
  end
  
  class Member < ApiItem  
    def to_s
      "Member #{self.id} named #{self.name}"
    end
  end
  
  class Photo < ApiItem
    def to_s
      "Photo #{self.id} named #{self.name}"
    end
  end
  
  class Topic < ApiItem
    def photos(extraparams={})
      extraparams['topic_id'] = self.id
      @client.get_photos extraparams
    end
    
    def to_s
      "Topic #{self.id} named #{self.name}"
    end
  end
  
  class Comment < ApiItem
    def to_s
      "Comment #{self.id} named #{self.name}"
    end
  end
  
  # Base class for unexpected errors returned by the Client
  class BaseException < Exception
    attr_reader :problem

    def initialize(e)
      @problem = e
    end
    
    def to_s
      "#{self.problem}"
    end
  end

  class ClientException < BaseException
    attr_reader :description
    
    def initialize(error_json)
      @description = error_json['details']
      @problem = error_json['problem']
    end
    
    def to_s
      "#{self.problem}: #{self.description}"
    end
  end

end
