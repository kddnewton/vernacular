# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'vernacular'

Vernacular.configure(&:give_me_all_the_things!)
