"""
Masters Research: Online Bookstore Flask Application
Base application implementation for testing and research
"""

from flask import Flask, session, request, render_template, redirect, url_for, jsonify
import time
from decimal import Decimal, ROUND_HALF_UP
import json

app = Flask(__name__)
app.secret_key = 'masters-research-secret-key-2024'

# Sample book data for the bookstore
BOOKS = [
    {
        'id': 1,
        'title': 'The Great Gatsby',
        'author': 'F. Scott Fitzgerald', 
        'price': 15.99,
        'category': 'Classic',
        'stock': 50
    },
    {
        'id': 2,
        'title': 'To Kill a Mockingbird',
        'author': 'Harper Lee',
        'price': 12.50,
        'category': 'Classic',
        'stock': 30
    },
    {
        'id': 3, 
        'title': '1984',
        'author': 'George Orwell',
        'price': 10.75,
        'category': 'Dystopian',
        'stock': 25
    },
    {
        'id': 4,
        'title': 'Pride and Prejudice',
        'author': 'Jane Austen',
        'price': 14.25,
        'category': 'Classic', 
        'stock': 40
    }
]

def calculate_cart_total(items):
    """
    Original cart calculation implementation
    Used for research comparison with optimized version
    """
    if not items:
        return 0.0
    
    total = 0.0
    for item in items:
        price = item.get('price', 0.0)
        quantity = item.get('quantity', 0)
        total += price * quantity
    
    return total

def validate_payment(card_data):
    """
    Original payment validation implementation  
    Used for research comparison
    """
    errors = []
    
    # Basic validation
    card_number = str(card_data.get('number', '')).strip()
    if not card_number:
        errors.append("Card number is required")
    elif card_number.endswith('1111'):
        errors.append("Payment failed - test card")
    
    cvv = card_data.get('cvv', '')
    if not cvv:
        errors.append("CVV is required")
    
    expiry = card_data.get('expiry', '')
    if not expiry:
        errors.append("Expiry date is required")
    
    return {
        'success': len(errors) == 0,
        'errors': errors
    }

def apply_discount(subtotal, discount_code):
    """
    Original discount application implementation
    Used for research comparison
    """
    discount_rates = {
        'SAVE10': 0.10,
        'WELCOME20': 0.20
    }
    
    discount_rate = discount_rates.get(discount_code, 0.0)
    return subtotal * (1 - discount_rate)

# Flask Routes
@app.route('/')
def index():
    """Home page displaying available books"""
    return jsonify({
        'message': 'Online Bookstore API',
        'version': '1.0.0',
        'endpoints': {
            'books': '/api/books',
            'cart': '/api/cart', 
            'calculate': '/api/calculate-total',
            'discount': '/api/apply-discount',
            'checkout': '/api/checkout'
        },
        'research_info': {
            'purpose': 'Masters Research in Software Testing',
            'testing_framework': 'Advanced research methodologies',
            'optimization_comparison': 'Original vs optimized implementations'
        }
    })

@app.route('/api/books')
def get_books():
    """API endpoint to get all books"""
    return jsonify({
        'success': True,
        'books': BOOKS,
        'count': len(BOOKS)
    })

@app.route('/api/books/<int:book_id>')
def get_book(book_id):
    """API endpoint to get a specific book"""
    book = next((b for b in BOOKS if b['id'] == book_id), None)
    if book:
        return jsonify({
            'success': True,
            'book': book
        })
    else:
        return jsonify({
            'success': False,
            'error': 'Book not found'
        }), 404

@app.route('/api/calculate-total', methods=['POST'])
def api_calculate_total():
    """API endpoint for cart total calculation"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': 'No JSON data provided'
            }), 400
        
        items = data.get('items', [])
        total = calculate_cart_total(items)
        
        return jsonify({
            'success': True,
            'total': total,
            'item_count': len(items),
            'calculation_method': 'original'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/apply-discount', methods=['POST'])
def api_apply_discount():
    """API endpoint for discount application"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False, 
                'error': 'No JSON data provided'
            }), 400
        
        subtotal = data.get('subtotal', 0.0)
        discount_code = data.get('discount_code', '')
        
        discounted_total = apply_discount(subtotal, discount_code)
        
        return jsonify({
            'success': True,
            'original_total': subtotal,
            'discounted_total': discounted_total,
            'discount_code': discount_code,
            'discount_applied': discounted_total != subtotal
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/validate-payment', methods=['POST'])
def api_validate_payment():
    """API endpoint for payment validation"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': 'No JSON data provided' 
            }), 400
        
        validation_result = validate_payment(data)
        
        return jsonify({
            'success': validation_result['success'],
            'errors': validation_result.get('errors', []),
            'validation_method': 'original'
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/checkout', methods=['POST'])
def api_checkout():
    """API endpoint for complete checkout process"""
    try:
        data = request.get_json()
        if not data:
            return jsonify({
                'success': False,
                'error': 'No JSON data provided'
            }), 400
        
        cart_items = data.get('items', [])
        discount_code = data.get('discount_code', '')
        payment_data = data.get('payment', {})
        
        # Calculate subtotal
        subtotal = calculate_cart_total(cart_items)
        
        # Apply discount
        total = apply_discount(subtotal, discount_code)
        
        # Validate payment
        payment_validation = validate_payment(payment_data)
        
        if not payment_validation['success']:
            return jsonify({
                'success': False,
                'errors': payment_validation['errors'],
                'step': 'payment_validation'
            }), 400
        
        # Simulate order processing
        order_id = f"ORD{int(time.time())}"
        
        return jsonify({
            'success': True,
            'order_id': order_id,
            'subtotal': subtotal,
            'discount_applied': total != subtotal,
            'total': total,
            'items_processed': len(cart_items),
            'timestamp': time.time()
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/research/comparison')
def research_comparison():
    """Research endpoint showing comparison between implementations"""
    test_items = [
        {'price': 15.99, 'quantity': 2},
        {'price': 12.50, 'quantity': 1}
    ]
    
    # Original implementation results
    original_total = calculate_cart_total(test_items)
    
    # Try to get optimized results if available
    try:
        from app_optimized import calculate_cart_total_research
        optimized_total = calculate_cart_total_research(test_items)
        optimization_available = True
    except ImportError:
        optimized_total = original_total
        optimization_available = False
    
    return jsonify({
        'research_comparison': {
            'test_case': test_items,
            'original_implementation': {
                'total': original_total,
                'method': 'basic_float_arithmetic'
            },
            'optimized_implementation': {
                'total': optimized_total,
                'method': 'research_optimized',
                'available': optimization_available
            },
            'difference': abs(original_total - optimized_total),
            'purpose': 'Masters Research Performance Comparison'
        }
    })

@app.route('/api/debug/session')
def debug_session():
    """Debug endpoint to check session state"""
    return jsonify({
        'session_keys': list(session.keys()) if session else [],
        'session_data': dict(session) if session else {}
    })

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': time.time(),
        'version': '1.0.0',
        'research_implementation': True
    })

# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({
        'success': False,
        'error': 'Endpoint not found'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        'success': False,
        'error': 'Internal server error'
    }), 500

if __name__ == '__main__':
    print("🎓 Masters Research: Online Bookstore Application")
    print("📚 Purpose: Software Testing Research and Optimization")
    print("🔬 Testing Framework: Advanced Research Methodologies")
    print("🚀 Starting Flask development server...")
    
    app.run(
        debug=True,
        host='0.0.0.0', 
        port=5000,
        use_reloader=True
    )
