# Shop manual smoke-test checklist

Use this checklist to record a manual audit run. Check an item only after verifying it in the running app.

- **Tester:**
- **Date:**
- **Environment / branch:**

## Accounts and listings

- [ ] Register the first user and sign in. Confirm the account was created.
- [ ] As the first user, try to edit or delete a listing created by another user. Confirm both actions are denied.
- [ ] Create a product listing as the first user. Confirm it is saved.
- [ ] Edit the first user's own listing. Confirm the changes are saved.
- [ ] Register and sign in as a second user.
- [ ] Create at least two listings as the second user. Confirm both are saved.
- [ ] Sign in as the first user. Confirm the second user's listings are visible.
- [ ] As a user, delete one of your own listings. Confirm it is deleted.
- [ ] Browse listings and confirm the seller's name is shown for each product without opening its detail page.

## Cart for a signed-in user

- [ ] Confirm the cart icon is visible on the homepage.
- [ ] As the first user, add one product to the cart. Confirm it appears in the cart and the message “Added to your cart” is shown.
- [ ] Confirm the cart badge shows `1`.
- [ ] Add four more products. Confirm all five items appear in the cart and the badge shows `5`.
- [ ] Confirm the cart shows the correct total for all items.
- [ ] Remove one item. Confirm it is removed and the message “Removed from your cart” is shown.
- [ ] Confirm the total updates and the badge shows `4`.
- [ ] Sign in as the second user. Confirm their cart is empty and the first user's cart remains separate.

## Guest cart and empty cart

- [ ] Sign out and add products as a guest. Confirm they appear in the guest cart.
- [ ] Sign in as a user. Confirm the guest cart items are present in that user's cart.
- [ ] Add products to the cart and choose **Empty Cart**. Confirm an “Are you sure?” prompt appears.
- [ ] Confirm the empty-cart action. Confirm the cart is cleared and you are redirected to the homepage.

## Bonus checks

- [ ] Add a new brand or product category.
- [ ] Add a product to the cart without opening its listing.
- [ ] Add four products from the same seller, remove one, and confirm the other three remain.
- [ ] Confirm the app has a custom design.
- [ ] Confirm a payment method is implemented.

## Notes

- **Failed checks / details:**
- **Follow-up work:**
