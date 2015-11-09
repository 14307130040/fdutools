# global constants and classes
@jQuery = @$ = require 'jquery'
require 'bootstrap'
@email = require 'emailjs'
@fs = require 'fs'
@Imap = require 'imap'
@tmpdir = require('os').tmpdir()
@path = require 'path'
@root = exports ? this
@mime = require 'mime'
@MailParser = require("mailparser").MailParser
@remote = require 'remote'
@dialog = remote.require 'dialog'

# global functions and other implementations

# a jquery plugin to autoload the
$("ul.selector li").click () ->
  old_page = $(this).attr 'data-bind'
  $(old_page).empty()
  target_page = $(this).attr 'data-bind'
  target_url = $(target_page).attr 'data-src'
  $(target_page).load target_url

# a bar showing the tips
@showTip = (tip) ->
  $("\#tips").html(tip).fadeIn "slow"

@hideTip = ()->
  $("\#tips").fadeOut("slow")

@flashTip = (tip) ->
  $("\#tips").html(tip).fadeIn "slow", hideTip
