#!/bin/sh

set -eu

gem install --no-document checkstyle_filter-git saddler saddler-reporter-github\
swiftlint_translate_checkstyle_format

sed -i -e 's/# reporter: json/reporter: json/g' .swiftlint.yml

if [ -z "${TRAVIS_PULL_REQUEST}" ]; then
    # when not pull request
    REPORTER=Saddler::Reporter::Github::CommitReviewComment
else
    REPORTER=Saddler::Reporter::Github::PullRequestReviewComment
fi

echo "********************"
echo "* SwiftLint        *"
echo "********************"
swiftlint > swiftlint.result.json
cat swiftlint.result.json
    | swiftlint_translate_checkstyle_format translate \
    | checkstyle_filter-git diff origin/master \
    | saddler report --require saddler/reporter/github --reporter $REPORTER
