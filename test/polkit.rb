# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

require "polkit"

describe Polkit do
  it "defines the namespace from the typelib" do
    # Not an arbitrary number: it is the point of the loader. A hand-written
    # binding exposes what someone got round to wrapping; this exposes what
    # polkit has, which is about twenty names. A drop to single digits means
    # the loader found the typelib and then silently half-ran.
    expect(Polkit.constants.size).to be > 15
  end

  it "defines the classes a caller actually reaches for" do
    expect(Polkit.const_defined?(:Authority)).to be == true
    expect(Polkit.const_defined?(:Subject)).to be == true
    expect(Polkit.const_defined?(:Identity)).to be == true
    expect(Polkit.const_defined?(:UnixUser)).to be == true
    expect(Polkit.const_defined?(:UnixProcess)).to be == true
    expect(Polkit.const_defined?(:AuthorizationResult)).to be == true
    expect(Polkit.const_defined?(:Details)).to be == true
  end

  it "maps instance methods onto a class, not just constants" do
    # A loader that registered the GTypes but no methods would still satisfy
    # every assertion above, so this is the one that catches a half-load.
    # polkit_authority_* is a couple of dozen entry points.
    own = Polkit::Authority.instance_methods - Object.instance_methods

    expect(own.size).to be > 15
  end

  it "builds a GObject subclass from a construct property" do
    # Does not touch D-Bus: polkit_unix_user_new is a plain GObject
    # construction, and the loader turns its `uid` property into a keyword.
    user = Polkit::UnixUser.new(uid: 0)

    expect(user).to be_a(Polkit::UnixUser)
    expect(user).to be_a(GLib::Object)
    expect(user.uid).to be == 0
  end

  it "resolves a name through a C constructor the typelib describes" do
    expect(Polkit::UnixUser.new_for_name("root").uid).to be == 0
  end

  it "parses an identity string into the right subclass" do
    # Identity is a GInterface, and from_string returns whichever
    # implementation matches -- so this exercises interface dispatch, not just
    # a constructor.
    identity = Polkit::Identity.from_string("unix-user:root")

    expect(identity).to be_a(Polkit::UnixUser)
    expect(identity.to_s).to be == "unix-user:root"
  end

  it "parses a subject string into the right subclass" do
    subject = Polkit::Subject.from_string("unix-process:1:1")

    expect(subject).to be_a(Polkit::UnixProcess)
  end

  it "round-trips a value through Details" do
    # A boxed type with out-parameters, which is a different code path in the
    # loader than a GObject with properties.
    details = Polkit::Details.new
    details.insert("polkit.message", "test")

    expect(details.lookup("polkit.message")).to be == "test"
  end

  it "defines the enumerations and flags the API takes" do
    expect(Polkit::CheckAuthorizationFlags).not.to be_nil
    expect(Polkit::ImplicitAuthorization).not.to be_nil
  end

  # Deliberately not tested: Polkit::Authority.get_sync. It is the first call a
  # real caller makes, but it connects to the system bus and needs polkitd
  # answering on it, which a CI container does not have. Asserting the class
  # and its method table is what can be checked without a running daemon.
end
