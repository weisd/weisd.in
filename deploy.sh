# mkdir .deploy && cd .deploy &&
# git clone --depth 1 --branch master --single-branch git@github.com:weisd/weisd.github.io.git . &&
cd .deploy && rm -rf ./* && cp -r ../public/* . &&
git add -A . &&  git commit -m "Site updated at  `date +"%Y-%m-%d %H:%M"` :octocat:" &&
git branch -m master && git push -q -u origin master