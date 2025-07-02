import unittest
import sys
import os

# Add the backend directory to Python path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from test_database import TestTaskDatabase
from test_models import TestTaskModel
from test_app import TestFlaskApp

if __name__ == '__main__':
    # Create test suite
    test_suite = unittest.TestSuite()
    
    # Add database tests
    test_suite.addTest(unittest.makeSuite(TestTaskDatabase))
    
    # Add model tests
    test_suite.addTest(unittest.makeSuite(TestTaskModel))
    
    # Add Flask app tests
    test_suite.addTest(unittest.makeSuite(TestFlaskApp))
    
    # Run tests
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(test_suite)
    
    # Print summary
    print(f"\n{'='*50}")
    print(f"Tests run: {result.testsRun}")
    print(f"Failures: {len(result.failures)}")
    print(f"Errors: {len(result.errors)}")
    print(f"Success rate: {((result.testsRun - len(result.failures) - len(result.errors)) / result.testsRun * 100):.1f}%")
    print(f"{'='*50}")