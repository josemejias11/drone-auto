# Contributing to DJI Drone Automation App 🚁

First off, thank you for considering contributing to this project! It's people like you that make the drone development community awesome.

## Code of Conduct

This project and everyone participating in it is governed by our commitment to creating a welcoming, inclusive environment. By participating, you are expected to uphold high standards of professionalism and safety.

## How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check the existing issues as you might find that the bug has already been reported. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples and sample code**
- **Include screenshots if applicable**
- **Specify your iOS version and drone model**
- **Include relevant log output**

### 🚀 Suggesting Features

Feature suggestions are welcome! Please provide:

- **A clear and detailed explanation of the feature**
- **Use cases and examples**
- **Any alternative solutions you've considered**
- **Priority level and impact assessment**

### 📝 Code Contributions

#### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/drone-auto.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Set up the development environment following the README instructions

#### Coding Standards

- **Swift Style Guide**: Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- **Code Formatting**: Use SwiftFormat or similar tools
- **Documentation**: Add comprehensive documentation for public APIs
- **Error Handling**: Implement proper error handling with descriptive messages
- **Safety First**: All drone-related code must include appropriate safety checks

#### Testing

- Write unit tests for new functionality
- Ensure all existing tests pass
- Test on real hardware when possible
- Include integration tests for drone communication

#### Pull Request Process

1. **Update Documentation**: Update README.md and code documentation
2. **Add Tests**: Include appropriate test coverage
3. **Safety Review**: Ensure all safety checks are in place
4. **Code Review**: Request review from maintainers
5. **Clean History**: Squash commits into logical units

### 📚 Documentation

Help improve our documentation:

- Fix typos and grammar
- Add examples and use cases  
- Improve setup instructions
- Create tutorials and guides
- Translate documentation

### 🛡️ Safety Guidelines

**CRITICAL**: All contributions must prioritize safety:

- ✅ Never bypass safety checks
- ✅ Include appropriate error handling
- ✅ Validate all flight parameters
- ✅ Test in safe, controlled environments
- ✅ Follow local aviation regulations
- ✅ Include comprehensive logging

## Development Guidelines

### Architecture Principles

- **MVCS Pattern**: Maintain Model-View-Controller-Service separation
- **Dependency Injection**: Use dependency injection where appropriate
- **Protocol-Oriented**: Prefer protocols over inheritance
- **Thread Safety**: Ensure thread-safe operations
- **Memory Management**: Avoid retain cycles and memory leaks

### Code Review Checklist

- [ ] Code follows Swift style guidelines
- [ ] All safety checks are implemented
- [ ] Error handling is comprehensive
- [ ] Documentation is complete and accurate
- [ ] Tests are included and passing
- [ ] No hard-coded values or magic numbers
- [ ] Proper logging is implemented
- [ ] Performance impact is considered

### Commit Message Guidelines

Use clear, descriptive commit messages:

```
🐛 Fix coordinate validation in FlightPlan

- Add bounds checking for latitude/longitude
- Include elevation validation (5m-500m)
- Add comprehensive error messages
- Update unit tests for edge cases

Fixes #123
```

#### Commit Types

- 🚁 `:helicopter:` - Drone-specific features
- ✨ `:sparkles:` - New features
- 🐛 `:bug:` - Bug fixes
- 🛡️ `:shield:` - Safety improvements
- 📝 `:memo:` - Documentation
- 🎨 `:art:` - Code structure/format
- ⚡ `:zap:` - Performance improvements
- 🔧 `:wrench:` - Configuration changes
- ✅ `:white_check_mark:` - Tests

## Getting Help

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussions
- **DJI Developer Forums**: For DJI SDK specific questions
- **Stack Overflow**: Tag questions with `dji-sdk` and `ios`

## Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes for significant contributions
- Special recognition for safety improvements

## Legal Notice

By contributing to this project, you agree that your contributions will be licensed under the same license as the project. You also confirm that you have the right to grant this license.

---

**Thank you for contributing to making drone automation safer and more accessible!** 🚁✨
