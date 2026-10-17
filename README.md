# Imaginary Illuminations

Beautiful illuminated manuscripts that never existed.

Images of invented manuscripts, made with Stable Diffusion 1.x and posted by
the bot `@ImaginaryIlluminations@social.krebsco.de` between December 2022 and
May 2023. The project is finished; this is its catalogue, at
<https://kmein.github.io/imaginary-illuminations/>.

Each PNG still carries its generation parameters (prompt, seed, sampler) in a
`parameters` text chunk. The captions are those prompts.

Plates are ordered by visual similarity, not by date. Their numbers are what
the plate pages are linked by, so do not renumber them.

    nix shell nixpkgs#lua --command lua build.lua   # writes dist/

Pushing to `master` builds and deploys `dist/` through GitHub Actions.
