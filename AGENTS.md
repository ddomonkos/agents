# General guidelines

## Code organization

- Prefer to put the primary exports together with their interface towards the top of the file. Helper functions, constants, etc. should be below. The point is that, as a reader, when I open a file, I want to see the primary thing at the top.

## Documentation, comments, commit messages

- When writing a longer function/method, consider adding brief inline comments to make it easier to read
- Prefer to use simple(r) language, make it easy to read for humans. Sometimes it might be worth it to sacrifice some completeness in favor of readability.
- The length of the comment/commit message/documentation should usually reflect the complexity of the thing that is being described. In my own experience, I often treat long texts as something important. If they describe something trivial, I find it harder to see what's important and what isn't.

## Tests

- Prefer to use accessible selectors instead of test ids when possible/reasonable

## Reviewing code

For code reviews, please read the [reviewer guidelines](./REVIEWER.md).
