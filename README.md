# bs-odoc

Helper package to run [odoc][1] for bucklescript projects


## Install

Install the package:

```sh
npm install --save-dev @ristostevcev/bs-odoc
```

And make sure you also have `odoc` installed:

```sh
opam install odoc
```

Optionally add the executable to your `scripts` in `package.json`:

```json
{
  ...
  "scripts": {
    "clean": "bsb -clean-world",
    "build": "bsb -make-world",
    "watch": "bsb -make-world -w",
    "docs": "bs-odoc -g"
  },
  ...
}
```

For help, run `bs-odoc -h`.

It should work without configuring anything, but you need to have `odoc` installed. See the
[README][1] for how to install odoc for bucklescript.

If you have `odoc` installed, it might not be on your `PATH`. Make sure you ran the opam command to
fetch it's path info:

```sh
eval `opam config env`
```


## Differences from bsdoc

Currently there is [bsdoc][2], which is a more popular library currently. The reason why I'm still
using and maintaining this project is due to some limitations of `bsdoc` (version `6.0.0-alpha`):

- *Heavy on dependencies* since it's written in native ocaml and requires [esy][3]. This library is
  just a simple shell script wrapped in an npm package.
- *Doesn't support linux or windows*
- *Doesn't offer the ability to add an `index.mld` file* which is essential for writing nicer docs
- *Doesn't set things up for github*. The docs suggest adding a redirect file which is less than
  ideal. This library will prepare the docs so that they can be served by github immediately with
  no redirection.

That being said, it looks as though bsdoc is currently the official way to do things, and the
popularity of the package would likely mean that these issues would get resolved eventually, after
which this library would by likely be archived.


## License

See LICENSE

[1]: https://github.com/ocaml/odoc
[2]: https://github.com/reuniverse/bsdoc
[3]: https://github.com/esy/esy
