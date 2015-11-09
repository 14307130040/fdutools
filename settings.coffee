class Student
  constructor: ->
    @load()

  load: ->
    @uid = localStorage.getItem('uid')
    @uis_password = localStorage.getItem('uis_password')
    @mail_password = localStorage.getItem('mail_password')
    @mail_address = @uid + "@fudan.edu.cn"

  save: ->
    localStorage.setItem('uid', @uid)
    localStorage.setItem('uis_password', @uis_password)
    localStorage.setItem('mail_password', @mail_password)

@student = new Student
