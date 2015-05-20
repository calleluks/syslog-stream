# Syslog::Stream

Parse streams of RFC5424 Syslog messages

## Installation

Add this line to your application's Gemfile:

```ruby
gem "syslog-stream"
```

And then execute:

```sh
bundle
```

Or install it using gem(1):

```sh
gem install syslog-stream
```

## Usage

`Syslog::Stream::OctetCountingFraming.new` should be able to accept any IO
object.

```ruby
require "stringio"
require "syslog/stream"

io = StringIO.new(
  '176 <165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - ID47 '\
  '[exampleSDID@32473 iut="3" eventSource="Application" eventID="1011"] An '\
  'application event log entry...181 <165>1 2003-10-11T22:14:16.003Z '\
  'mymachine.example.com evntslog - ID48 [exampleSDID@32473 iut="3" '\
  'eventSource="Application" eventID="1012"] Another application event log '\
  'entry...',
)

stream = Syslog::Stream.new(Syslog::Stream::OctetCountingFraming.new(io))

stream.messages do |message|
  # The values below are for the first yield to this block. This block will be
  # yielded to, two times in total: Once for each messsage.
  message.prival          #=> 165
  message.facility        #=> 20
  message.severity        #=> 5
  message.version         #=> 1
  message.timestamp       #=> 2003-10-11 22:14:15 UTC
  message.timestamp.class #=> Time
  message.hostname        #=> "mymachine.example.com"
  message.app_name        #=> "evntslog"
  message.procid          #=> nil
  message.structured_data #=> [#<struct StructuredDataElement
  # id="exampleSDID@32473"@71, params={"iut"=>"3", "eventSource"=>"Application",
  # "eventID"=>"1011"}>]
  message.msg             #=> "An application event log entry..."
end
```

### Parsing streams received via Heroku HTTPS log drains

The cloud application platform [Heroku][heroku] allows it's users to register
log drains that receive Syslog formatted application log messages over HTTPS. As
outlined in [Heroku's documentation on HTTPS Log Drains][drains], these messages
do not fully conform to RFC5424:

> “application/logplex-1” does not conform to RFC5424. It leaves out
> STRUCTURED-DATA but does not replace it with a NILVALUE.

RFC5424 requires STRUCTURED-DATA to consist of either one NILVALUE or one or
more SD-ELEMENTs.

[heroku]: https://heroku.com
[drains]: https://devcenter.heroku.com/articles/log-drains#https-drains

In order to parse Syslog streams received via Heroku HTTPS log drains,
`Syslog::Stream` needs to be instantiated with a parser that allows missing
STRUCTURE-DATA:

```ruby
parser = Syslog::Parser.new(allow_missing_structured_data: true)

io = StringIO.new

stream = Syslog::Stream.new(
  Syslog::Stream::OctetCountingFraming.new(io),
  parser: parser,
)
```
