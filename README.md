# i18n-asf

This library extends the [Ruby i18n library](https://github.com/svenfuchs/i18n) that ships with Rails to add support for ASF (Adobe Strings Format), Adobe's XML-based alternative to ZStrings for localizing application UI text. While i18n is the Rails default, and this library has been written with a Rails application in mind, you can also use this gem to add ASF support to any Ruby project.

## Setup

Just add this library to your `Gemfile`, either in addition to or instead of `i18n`:

```ruby
gem 'i18n-asf', :git => "git@fit.corp.adobe.com:ddemaree/i18n-asf.git"
```

Once that's done, you will be able to add `.asf` translation files to your app's `config/locales` directory alongside the `.yml` or `.rb` formats supported by the core library.

## Usage

The [Rails Internationalization Guide](http://guides.rubyonrails.org/i18n.html) provides a good overview of the i18n library and how to use it in a Rails project. Below you'll find a brief overview of ASF and how its structure maps to features and concepts in the core i18n framework.

ASF is a fairly lightweight XML grammar. Documents consist of an `asf` tag, which in turn can contain `str` (string) or `set` tags, both of which are identified by a `name` attribute. Both kinds of elements can have a `desc` element, used to describe the element's purpose and provide context for the translators. ASF strings can have multiple values, and both strings and sets can support arbitrary key-value metadata, though neither of these features are used here.

Here's an example of a valid ASF document:

```xml
<?xml version="1.0" encoding="utf-8" standalone="no" ?>
<!DOCTYPE asf SYSTEM "http://ns.adobe.com/asf/asf_1_0.dtd">
<asf version="1.0" locale="en_US" xmlns="http://ns.adobe.com/asf">
  <str name="simple">
    <desc>Example of a simple string definition</desc>
    <val>Add to Kit</val>
  </str>
  <set name="browse">
    <desc>Strings for the font browsing UI</desc>
    <str name="font_count_heading">
      <desc>Text for heading that includes the number of fonts on the page</desc>
      <val>Showing <param name="font_count"/> fonts</val>
    </str>
  </set>
</asf>
```

ASF files are parsed into a Ruby hash structure, following the same general nesting and structural conventions the i18n library expects:

```ruby
:en => {
  :simple => "Add to Kit",
  :browse => {
    :font_count_heading => "Showing %{font_count} fonts"
  }
}
```

As of version 0.0.3, `i18n-asf` uses the `locale` attribute of the top-level `asf` tag (if present) to determine the locale for a given set of strings, so all the strings included in the example code above would be assigned to the `:en_US` locale.

If the `locale` attribute is not present, translations are assigned to a locale based on their filename (per the I18n library's default behavior), i.e. a file named `de.asf` will be assigned to the `:de` locale.

In your Rails app you can refer to these translations by a scoped identifier, and take advantage of I18n features such as interpolation, pluralization, date and number conversion, and so on.

```ruby
# This method is aliased as `t()` in Rails ERb views
I18n.translate("browse.font_count_heading", :count => 22)
#=> "Showing 22 fonts"
```

Calls to `translate` can take a `:scope` parameter, which can help DRY up your code:

```ruby
# These are all roughly equivalent
I18n.translate("index.font_count_heading", :count => 22, :scope => "browse")
I18n.translate("font_count_heading", :count => 22, :scope => "browse.index")
I18n.translate("font_count_heading", :count => 22, :scope => ["browse", "index"])
```
