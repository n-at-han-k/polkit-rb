# polkit

Ruby bindings for polkit, asking whether an unprivileged process may do a privileged thing.

```ruby
require "polkit"

# Who is asking, and about what.
user = Polkit::UnixUser.new_for_name("root")
subject = Polkit::Subject.from_string("unix-process:#{Process.pid}:1")

# And the question itself, which needs polkitd on the system bus.
authority = Polkit::Authority.get_sync
result = authority.check_authorization_sync(
  subject, "org.freedesktop.policykit.exec", nil,
  Polkit::CheckAuthorizationFlags::ALLOW_USER_INTERACTION, nil,
)
result.authorized?
```

## How this works, and what it costs to install

polkit ships a GObject Introspection typelib — `Polkit-1.0.typelib` — describing
every class, method, property and signal it has. `Polkit::Loader`, about twenty
lines, hands that to ruby-gnome's `GObjectIntrospection::Loader`, which defines
the Ruby classes from it at `require` time.

So this gem is pure Ruby: no extension of its own, no Cargo workspace, no
per-platform binary. You get the whole library rather than the subset somebody
got round to wrapping by hand, and it does not drift when the library gains API.

Be precise about install, though: `gem install polkit` still compiles C, because
`gobject-introspection` and `glib2` are themselves native extensions built
against glib, so a compiler and glib's development headers are needed. What
this gem adds on top is nothing — those two are what every ruby-gnome
application already has, since `gtk4` depends on them.

## Two namespaces, one gem

polkit is two libraries with two typelibs, and this gem has a loader for each:

| require | namespace | what it is for |
|---|---|---|
| `require "polkit"` | `Polkit` | the asking side: `Authority`, `Subject`, `Identity`, `AuthorizationResult` |
| `require "polkit/agent"` | `PolkitAgent` | the answering side: subclass `Listener` to *be* the process that shows the authentication prompt |

Most callers only ever ask, so `polkit/agent` is a separate require. Both
typelibs come from the same distribution package, so if one loads the other
does. If you are writing the GNOME authentication dialog in Ruby GTK,
`PolkitAgent::TextListener` is the implementation polkit ships and the one to
read first.

## The one thing you must install

The typelib is a C-library artefact, so it belongs to your distribution and
this gem cannot install it:

| | |
|---|---|
| Debian / Ubuntu | `gir1.2-polkit-1.0` |
| Fedora | `polkit-libs` |
| Arch | `polkit` |
| nix | `pkgs.polkit` |

If it is not in the default search path, point `GI_TYPELIB_PATH` at the
directory holding `Polkit-1.0.typelib`. The dev shell in `flake.nix` does this.

Under nix there is one more wrinkle: `pkgs.polkit` resolves to its `bin`
output, which has no typelibs — they are in `polkit.out`, exactly as glib's
are. `flake.nix` builds the search path with
`map (drv: drv.out or drv)` for that reason.

**One trap worth knowing.** The typelib must come from the same glib build as
the `gobject-introspection` gem. Mixing two registers GIO twice in one process
and fails with `cannot register existing type 'GTlsCertificate'`. Under nix,
take both from one nixpkgs — and note that glib's typelibs live in its `out`
output, not the default one.

## Development

```sh
nix develop
bin/test
```

## Licence

Apache-2.0. The library itself keeps its own licence; this gem links nothing
and copies no code from it — it reads a description of it at runtime.
