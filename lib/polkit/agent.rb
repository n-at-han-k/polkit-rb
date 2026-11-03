# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

require_relative "../polkit"
require_relative "agent/loader"

# The authentication-agent half of polkit.
#
# `require "polkit"` gives you the asking side: {Polkit::Authority} and the
# subjects and identities you ask it about. This gives you the answering side --
# {PolkitAgent::Listener}, which you subclass to become the process that shows
# the authentication prompt, and {PolkitAgent::Session}, which drives one
# attempt. `PolkitAgent::TextListener` is the terminal implementation polkit
# ships, and is the one to read first.
#
# It is a separate require because it is a separate GI namespace with its own
# typelib, and most callers only ever want to ask. Both typelibs come from the
# same polkit package, so if `require "polkit"` works this does too.
module PolkitAgent
  loader = Loader.new(self)
  loader.load
end
