# Alyssa created the following code to keep track of items for a shopping cart application she's writing:

class InvoiceEntry
  attr_reader :quantity, :product_name

  def initialize(product_name, number_purchased)
    @quantity = number_purchased
    @product_name = product_name
  end

  def update_quantity(updated_count)
    # prevent negative quantities from being set
    @quantity = updated_count if updated_count >= 0
  end
end

# Alan looked at the code and spotted a mistake. "This will fail when update_quantity is called", he says.
#
# Can you spot the mistake and how to address it?

invoice_1 = InvoiceEntry.new("OMO", 5)
puts invoice_1.update_quantity(5)
