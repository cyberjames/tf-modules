## Terraform modules

A few re-usable TF modules to speed up the dev process.

### Modules 

- [Networking](./networking/README.md)


### Versioning with tags

**Publish tags:**
```sh
git tag -a "v1.0.1" -m "First release of tf modules"
git push origin master --follow-tags
```
**Usage:**

```tf
module "networking" {
  source = "github.com/Jareechang/tf-modules//networking?ref=v1.0.1"
}
```
