# DEPRECATED

This project is deprecated and unmaintained. Use the [bsdoc][2] package instead.

# bs-odoc

Helper package to run [odoc][1] for bucklescript projects 

## Install

Install the package:

```sh
npm install --save-dev @ristostevcev/bs-odoc
```

Optionally add the executable to your `scripts` in `package.json`:

```json
{
  ...
  "scripts": {
    "clean": "bsb -clean-world",
    "build": "bsb -make-world",
    "watch": "bsb -make-world -w",
    "docs": "bs-odoc"
  },
  ...
}
```

It should work without configuring anything, but you need to have `odoc` 
installed. See the [README][1] for how to install odoc for bucklescript.

If you have odoc installed, it might not be on your `PATH`. Make sure you ran 
the opam command to fetch it's path info:

```sh
eval `opam config env`
```

## License

See LICENSE

[1]: https://github.com/ocaml/odoc
[2]: https://github.com/reuniverse/bsdoc
