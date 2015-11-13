# the page is loaded
inspect = require('util').inspect

class Receiver
  constructor: ->
    @imap = new Imap user: student.mail_address, password: student.mail_password,
    port: 993, host: "mail.fudan.edu.cn", tls: true
    @imap.once 'error', (err) ->
      console.log err
    @imap.once 'end', ->
      console.log 'Connection ended'

  fetchBox: (name, range, callback)->
    @imap.once 'ready', =>
      @imap.openBox name, true, (err, box) =>
        throw err if err
        @imap.search [ 'ALL'], (err, results) =>
          throw err if err
          for i in results.reverse()[range[0]..range[1]]
            f = @imap.fetch i, bodies: 'HEADER.FIELDS (FROM TO SUBJECT DATE)', struct: true
            f.on 'message', (msg, seqno) ->
              msg.on 'body', (stream, info) ->
                buffer = ""
                stream.on 'data', (chunk) -> buffer += chunk.toString('utf8')
                stream.once 'end', ->
                  data = Imap.parseHeader(buffer)
                  data.seqno = seqno
                  callback? data
              # msg.once 'attributes', (attrs) -> result[seqno].attrs = attrs
            f.once 'error', (err) -> console.log 'Fetch error: ' + err
            f.once 'end', => @imap.end()
    @imap.connect()

  fetchDetail: (name, theSeqno, callback) ->
    emlFile = "#{tmpdir}#{path.sep}#{name}-msg-#{theSeqno}-body.eml"
    mail = ""
    fs.exists emlFile, (exist) ->
        if exist
          callback? emlFile
          return
    @imap.once 'ready', =>
      @imap.openBox name, true, (err, box) =>
        throw err if err
        f = @imap.seq.fetch theSeqno, bodies: '', struct: true
        f.on 'message', (msg, seqno) ->
          msg.on 'body', (stream, info) ->
            wfs = fs.createWriteStream(emlFile)
            wfs.on 'close', ->
              callback? emlFile
            stream.pipe wfs
        f.once 'error', (err) -> console.log 'Fetch error: ' + err
        f.once 'end', => @imap.end()
    @imap.connect()

class Sender
  constructor: ->
    @server = email.server.connect user: student.mail_address, password: student.mail_password,
    host: "mail.fudan.edu.cn", ssl: true

  send: (text, from, to, cc, subject, attachment) ->
    message =
      text: text
      from: "#{from} <#{student.mail_address}>"
      to: to
      cc: cc
      subject: subject

    message.attachment = attachment if attachment
    @server.send message, (err, message) -> console.log err || message

@m = new Receiver
@s = new Sender

@fetchSumary =  ->
  showTip "正在拉取邮件..."
  getData = (data)->
    domNode = $("<tr data-seqno=\"#{data.seqno}\"><td>#{data.from}</td><td>#{data.subject}</td><td>#{data.date}</td></tr>")
    domNode.click ->
      showTip "正在下载邮件..."
      m.fetchDetail 'INBOX', $(this).attr('data-seqno'), (emlFile) ->
        mailparser = new MailParser showAttachmentLinks: true, streamAttachments: true
        mailparser.on "end", (mail_object) ->
          re = /src="cid:(.*)"/g
          if html = mail_object.html
            while html.search(re) != -1
              html = html.replace re, "src=\"file:#{tmpdir}#{path.sep}$1\""
          $("\#detail td div").html html ? mail_object.text

        mailparser.on "attachment", (attachment, mail) ->
          output = fs.createWriteStream(tmpdir + path.sep + attachment.contentId);
          attachment.stream.pipe(output);
        fs.createReadStream(emlFile).pipe mailparser
        hideTip()

    $("\#summary tbody").append domNode
  m.fetchBox "INBOX", [0], getData
  hideTip()

attachments = []
@sendmail = ->
  text = $("\#editor").html()
  from = $("\#from").val()
  to = $("\#to").val()
  cc = $("\#cc").val()

  attachments.push data: text, alternative: true
  subject = $("\#subject").val()

  s.send '', from, to, cc, subject, attachments

@attach = ->
  files = dialog.showOpenDialog properties: ['openFile', 'multiSelections']
  for i in files
    index = attachments.length
    attachments.push path: i, type: mime.lookup(i), name: path.parse(i).base
    domNode = $("<li data-index=\"#{index}\">#{path.parse(i).name}<i onclick=\"deleteAttachment($(this).parent());\" class=\"glyphicon glyphicon-remove\"></i></li>")
    $("\#attachments_element").append(domNode)

@deleteAttachment = (target) ->
  attachments.splice target.attr('data-index'), 1
  target.remove()

$(this).ready ->
  $("\#fetch").click fetchSumary
  $("\#send").click sendmail
  $("\#attacher").click attach
  $("\#editor").wysiwyg()
  fetchSumary()
