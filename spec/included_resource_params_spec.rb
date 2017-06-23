require_relative '../included_resource_params'

describe IncludedResourceParams do
  subject(:parser) { IncludedResourceParams.new(include_param: include_param) }

  let(:include_param) { include_param_array.join(',') }
  let(:include_param_array) { %w(foo foo.bar foo.*) }

  describe '#has_included_resources?' do
    subject { parser.has_included_resources? }

    context 'when the include param is nil' do
      let(:include_param) { nil }

      it { is_expected.to eq false }
    end

    context 'when the include param has only wild cards' do
      let(:include_param) { 'foo.**' }

      it { is_expected.to eq false }
    end

    context 'when the include param has non wildcard params' do
      let(:include_param) { 'foo' }

      it { is_expected.to eq true }
    end

    context 'when the include param has both wildcard and non wildcard params' do
      let(:include_param) { 'foo,bar.**' }

      it { is_expected.to eq true }
    end
  end

  describe '#included_resources' do
    subject { parser.included_resources }

    let(:include_param) { 'foo,foo.bar,baz.*,bat.**' }

    it 'returns only non wildcards' do
      is_expected.to eq ['foo', 'foo.bar']
    end

    context 'when the include param is nil' do
      let(:include_param) { nil }

      it { is_expected.to eq [] }
    end
  end

  describe '#model_includes' do
    subject { parser.model_includes }

    context 'when the include param is nil' do
      let(:include_param) { nil }

      it { is_expected.to eq [] }
    end

    context 'when it receives one single level resource' do
      let(:include_param) { 'foo' }

      it { is_expected.to eq [:foo] }
    end

    context 'when it receives multiple single level resources' do
      let(:include_param) { 'foo,bar' }

      it { is_expected.to eq [:foo, :bar] }
    end

    context 'when it receives single two level resource' do
      let(:include_param) { 'foo.bar' }

      it { is_expected.to eq [{:foo => [:bar]}] }
    end

    context 'when it receives multiple two level resources from the same table' do
      let(:include_param) { 'foo.bar,foo.bat' }

      it { is_expected.to eq [{:foo => [:bar, :bat]}] }
    end

    context 'when it receives multiple two level resource from different tables' do
      let(:include_param) { 'foo.bar,baz.bat' }

      it { is_expected.to eq [{:foo => [:bar]}, {:baz => [:bat]}] }
    end

    context 'when it receives three level resources' do
      let(:include_param) { 'foo.bar.baz' }

      it { is_expected.to eq [{:foo => [{:bar => [:baz]}]}] }
    end

    context 'when it receives multiple three level resources' do
      let(:include_param) { 'foo.bar.baz,foo,foo.bar.bat,bar' }

      it { is_expected.to eq [{:foo => [{:bar => [:baz, :bat]}]}, :bar] }
    end
  end
end
