require "minitest_helper"
require "stringio"

class StreamTest < Minitest::Test
  def test_octet_counting_framing
    io = StringIO.new(
      '172 <165>1 2003-10-11T22:14:15.003Z mymachine.example.com evntslog - '\
      'ID47 [exampleSDID@32473 iut="3" eventSource="Application" '\
      'eventID="1011"] An application event log entry...177 <165>1 '\
      '2003-10-11T22:14:16.003Z mymachine.example.com evntslog - ID48 '\
      '[exampleSDID@32473 iut="3" eventSource="Application" eventID="1012"] '\
      'Another application event log entry...',
    )
    stream = Syslog::Stream.new(Syslog::Stream::OctetCountingFraming.new(io))
    messages = []

    stream.messages { |message| messages << message }

    assert_equal 2, messages.length
    assert_equal 165, messages[0].prival
    assert_equal 20, messages[0].facility
    assert_equal 5, messages[0].severity
    assert_equal 1, messages[0].version
    assert_equal(
      Time.utc(2003, 10, 11, 22, 14, Rational("15003/1000")),
      messages[0].timestamp,
    )
    assert_equal "mymachine.example.com", messages[0].hostname
    assert_equal "evntslog", messages[0].app_name
    assert_equal nil, messages[0].procid
    assert_equal "ID47", messages[0].msgid
    assert_equal 1, messages[0].structured_data.length
    assert_equal "exampleSDID@32473", messages[0].structured_data[0].id
    params = {
      "iut" => "3",
      "eventSource" => "Application",
      "eventID" => "1011",
    }
    assert_equal params, messages[0].structured_data[0].params
    assert_equal "An application event log entry...", messages[0].msg
    assert_equal 165, messages[1].prival
    assert_equal 20, messages[1].facility
    assert_equal 5, messages[1].severity
    assert_equal 1, messages[1].version
    assert_equal(
      Time.utc(2003, 10, 11, 22, 14, Rational("16003/1000")),
      messages[1].timestamp,
    )
    assert_equal "mymachine.example.com", messages[1].hostname
    assert_equal "evntslog", messages[1].app_name
    assert_equal nil, messages[1].procid
    assert_equal "ID48", messages[1].msgid
    assert_equal 1, messages[1].structured_data.length
    assert_equal "exampleSDID@32473", messages[1].structured_data[0].id
    params = {
      "iut" => "3",
      "eventSource" => "Application",
      "eventID" => "1012",
    }
    assert_equal params, messages[1].structured_data[0].params
    assert_equal "Another application event log entry...", messages[1].msg
  end

  def test_passing_a_parser
    io = StringIO.new(
      "83 <40>1 2012-11-30T06:45:29+00:00 host app web.3 - State changed from "\
      "starting to up\n119 <40>1 2012-11-30T06:45:26+00:00 host app web.3 - "\
      "Starting process with command `bundle exec rackup config.ru -p 24405`\n",
    )
    stream = Syslog::Stream.new(
      Syslog::Stream::OctetCountingFraming.new(io),
      parser: Syslog::Parser.new(allow_missing_structured_data: true),
    )
    messages = []

    stream.messages { |message| messages << message }

    assert_equal 2, messages.length
    assert_equal 40, messages[0].prival
    assert_equal 5, messages[0].facility
    assert_equal 0, messages[0].severity
    assert_equal 1, messages[0].version
    assert_equal Time.utc(2012, 11, 30, 6, 45, 29), messages[0].timestamp
    assert_equal "host", messages[0].hostname
    assert_equal "app", messages[0].app_name
    assert_equal "web.3", messages[0].procid
    assert_equal nil, messages[0].msgid
    assert_equal nil, messages[0].structured_data
    assert_equal "State changed from starting to up\n", messages[0].msg
    assert_equal 40, messages[1].prival
    assert_equal 5, messages[1].facility
    assert_equal 0, messages[1].severity
    assert_equal 1, messages[1].version
    assert_equal Time.utc(2012, 11, 30, 6, 45, 26), messages[1].timestamp
    assert_equal "host", messages[1].hostname
    assert_equal "app", messages[1].app_name
    assert_equal "web.3", messages[1].procid
    assert_equal nil, messages[1].msgid
    assert_equal nil, messages[1].structured_data
    assert_equal "Starting process with command `bundle exec rackup config.ru "\
      "-p 24405`\n", messages[1].msg
  end

  def test_unicode_support
    io = StringIO.new(
      "60 <40>1 2012-11-30T06:45:29+00:00 - - - - - Some unicode: 😁55 <40>1 "\
      "2012-11-30T06:45:30+00:00 - - - - - That's enough",
    )
    stream = Syslog::Stream.new(Syslog::Stream::OctetCountingFraming.new(io))
    messages = []

    stream.messages { |message| messages << message }

    assert_equal 2, messages.length
    assert_equal "Some unicode: 😁", messages[0].msg
    assert_equal "That's enough", messages[1].msg
  end

  def test_returns_an_enumerator
    io = StringIO.new
    stream = Syslog::Stream.new(Syslog::Stream::OctetCountingFraming.new(io))

    assert_kind_of Enumerator, stream.messages
  end
end
