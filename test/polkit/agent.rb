# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

require "polkit/agent"

describe PolkitAgent do
  it "defines the namespace from the second typelib" do
    expect(PolkitAgent.constants.size).to be > 3
  end

  it "defines the classes an agent implementor reaches for" do
    expect(PolkitAgent.const_defined?(:Listener)).to be == true
    expect(PolkitAgent.const_defined?(:Session)).to be == true
    expect(PolkitAgent.const_defined?(:TextListener)).to be == true
  end

  it "maps instance methods onto a class, not just constants" do
    own = PolkitAgent::Listener.instance_methods - Object.instance_methods

    expect(own.size).to be > 15
  end

  it "loads alongside Polkit without registering a type twice" do
    # Both typelibs come from one package and depend on the same Gio. If they
    # ever came from different glib builds, requiring the second would die
    # with `cannot register existing type`, so reaching here is the assertion.
    expect(PolkitAgent::Listener.ancestors).to be(:include?, GLib::Object)
    expect(Polkit::UnixUser.new(uid: 0).uid).to be == 0
  end
end
