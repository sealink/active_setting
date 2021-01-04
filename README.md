# Setting

[![Gem Version](https://badge.fury.io/rb/active_setting.svg)](http://badge.fury.io/rb/active_setting)
[![Build Status](https://github.com/sealink/active_setting/workflows/Build%20and%20Test/badge.svg?branch=master)](https://github.com/sealink/active_setting/actions)
[![Build Status](https://codeclimate.com/github/sealink/active_setting.png)](https://codeclimate.com/github/sealink/active_setting)

# DESCRIPTION

A library for managing settings with various values/defaults/etc.

# INSTALLATION

gem install setting

or add to your Gemfile:
gem 'setting'

# SYNOPSIS

require 'setting'

For examples on most usage see the tests in the spec directory.
As these contain many basic examples with expected output.

# RELEASE

To publish a new version of this gem the following steps must be taken.

- Update the version in the following files
  ```
    CHANGELOG.md
    lib/active_setting/version.rb
  ```
- Create a tag using the format v0.1.0
- Follow build progress in GitHub actions
