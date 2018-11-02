CEF UPGRADE
===========

* Update upstream branches

```
$ cd  ~/dev/projects/cef/cef
$ git remote -v show
origin	git@github.com:tiliado/cef.git (fetch)
origin	git@github.com:tiliado/cef.git (push)
upstream	git@bitbucket.org:chromiumembedded/cef.git (fetch)
upstream	git@bitbucket.org:chromiumembedded/cef.git (push)
$ git fetch upstream
```

* Look at [supported upstream branches](https://bitbucket.org/chromiumembedded/cef/wiki/BranchesAndBuilding)
  and branch it.

```
git checkout upstream/3538
git checkout -b 3538
git checkout -b 3538-valacef
```

* Or update it:

```
git checkout 3538
git rebase upstream/3538
git checkout 3538-valacef
git rebase 3538
```

* Rebase patches

```
cd  ~/dev/projects/cef/cef
git checkout 3538-valacef
git cherry-pick ...
cd /media/fenryxo/exthdd7/cef/build/
wget https://bitbucket.org/chromiumembedded/cef/raw/07f57223a87f634dbb7ba6b3960251225413b9ac/tools/automate/automate-git.py
time python automate-git.py --download-dir=download \
  --url=/home/fenryxo/dev/projects/cef/cef --branch=3538 --checkout=origin/3538-valacef  \
  --force-clean --force-config  --x64-build --build-target=cefsimple --no-build --no-distrib
cd /media/fenryxo/exthdd7/cef/build/download/chromium/src/cef/tools
# Attempt to update patch files. Any merge conflicts will be highlighted in the output.
python patch_updater.py
cp -v /media/fenryxo/exthdd7/cef/build/download/chromium/src/cef/patch/patches/* /home/fenryxo/dev/projects/cef/cef/patch/patches
...
```
