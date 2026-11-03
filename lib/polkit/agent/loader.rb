# frozen_string_literal: true

# Released under the Apache License, Version 2.0.
# Copyright, 2026, by General Intelligence Systems.

module PolkitAgent
  # Defines everything in the PolkitAgent namespace from `PolkitAgent-1.0.typelib`.
  #
  # The same polkit package ships two typelibs: `Polkit-1.0` is the asking side
  # (may this subject do this action?), and `PolkitAgent-1.0` is the answering
  # side -- the API you implement to *be* the authentication agent that puts the
  # password prompt on screen. They are separate GI namespaces, so they need
  # separate loaders, but one library means one gem.
  #
  # Like Polkit, and unlike GtkSource, there is no init function to call: the
  # typelib declares none, so there is no pre_load hook here.
  class Loader < GObjectIntrospection::Loader
    def load
      self.version = "1.0"
      super("PolkitAgent")
    end

    private

    def post_load(repository, namespace)
      require_libraries
    end

    def require_libraries
      # Nothing yet. Hand-written Ruby that improves on the typelib goes in
      # files required from here, which is the convention ruby-gnome uses.
    end
  end
end
