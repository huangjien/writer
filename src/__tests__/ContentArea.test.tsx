import React from 'react';
import { render } from '@testing-library/react-native';
import { ContentArea } from '../components/ContentArea';

// Mock the global module
jest.mock('@/components/global', () => ({
  CONTENT_KEY: 'content_',
}));

describe('ContentArea', () => {
  const defaultProps = {
    current: 'test-file.md',
    content: 'Hello World',
    fontSize: 16,
    top: 0,
  };

  describe('Basic Functionality', () => {
    it('should render without crashing', () => {
      const component = render(<ContentArea {...defaultProps} />);
      expect(component).toBeTruthy();
    });

    it('should render with content', () => {
      const component = render(<ContentArea {...defaultProps} />);
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle empty content', () => {
      const component = render(<ContentArea {...defaultProps} content='' />);
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle undefined current prop', () => {
      const component = render(
        <ContentArea {...defaultProps} current={undefined} />
      );
      expect(component.toJSON()).toBeTruthy();
    });
  });

  describe('Props Handling', () => {
    it('should accept all props without error', () => {
      const component = render(
        <ContentArea
          current='test.md'
          content='Test content'
          fontSize={18}
          top={10}
          currentParagraphIndex={0}
          isReading={true}
        />
      );
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle reading mode props', () => {
      const component = render(
        <ContentArea
          {...defaultProps}
          isReading={true}
          currentParagraphIndex={0}
        />
      );
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle different font sizes', () => {
      const component = render(<ContentArea {...defaultProps} fontSize={24} />);
      expect(component.toJSON()).toBeTruthy();
    });
  });

  describe('Content Processing', () => {
    it('should handle single paragraph content', () => {
      const component = render(
        <ContentArea {...defaultProps} content='Single paragraph' />
      );
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle multi-paragraph content', () => {
      const content = 'First paragraph\n\nSecond paragraph';
      const component = render(
        <ContentArea {...defaultProps} content={content} />
      );
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle content with whitespace', () => {
      const content = '   Paragraph with spaces   \n\n   Another paragraph   ';
      const component = render(
        <ContentArea {...defaultProps} content={content} />
      );
      expect(component.toJSON()).toBeTruthy();
    });
  });

  describe('Component Structure', () => {
    it('should render with valid JSON structure', () => {
      const component = render(<ContentArea {...defaultProps} />);
      const json = component.toJSON();
      expect(json).toBeDefined();
    });

    it('should render component tree successfully', () => {
      const component = render(<ContentArea {...defaultProps} />);
      expect(component.toJSON()).toBeDefined();
    });
  });

  describe('Edge Cases', () => {
    it('should handle very long content', () => {
      const longContent = 'A'.repeat(10000);
      const component = render(
        <ContentArea {...defaultProps} content={longContent} />
      );
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle special characters in content', () => {
      const specialContent = 'Content with émojis 🚀 and spëcial chars!';
      const component = render(
        <ContentArea {...defaultProps} content={specialContent} />
      );
      expect(component.toJSON()).toBeTruthy();
    });

    it('should handle negative currentParagraphIndex', () => {
      const component = render(
        <ContentArea
          {...defaultProps}
          currentParagraphIndex={-1}
          isReading={true}
        />
      );
      expect(component.toJSON()).toBeTruthy();
    });
  });
});
