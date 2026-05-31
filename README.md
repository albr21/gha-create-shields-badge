# gha-create-shields-badge

A GitHub Action to create a badge using [shields.io](https://shields.io) API.

## Usage

```yaml
steps:
  - name: Create Shields Badge
    uses: albr21/gha-create-shields-badge@1.0.0
    with:
      label: my-label
      message: my-message
      color: my-color
      label-color: my-label-color
      logo: my-logo
      logo-color: my-logo-color
      style: my-style
      format: my-format
      base-url: my-base-url
```

## Contributing

Check out the [CONTRIBUTING](CONTRIBUTING.md) file for guidelines on how to contribute to this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
