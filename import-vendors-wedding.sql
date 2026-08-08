-- Bulk import: vendors from Wedding_tracker_.xlsx, added to Wedding
-- 8 vendors, all marked 'booked' with deposit already paid
insert into vendors (event_id, category, name, status, payment_status, price, deposit_amount, due_date, notes) values
  ('wedding', 'Hotel', 'Shangri-La', 'booked', 'deposit_paid', 4123020.00, 1240000.00, '2027-10-05', 'Deposit paid 24 Jun 2026. Remaining balance split into two installments (~LKR 1,151,352 + ~LKR 1,731,668); second installment due 5 Oct 2027, payable 1 month prior.'),
  ('wedding', 'Photography & Videography', 'Beyond Destiny', 'booked', 'deposit_paid', 880000.00, 264000.00, '2027-06-03', 'Deposit paid 8 Jul 2026. Final payment due 1 week prior.'),
  ('wedding', 'Emcee', 'Joel', 'booked', 'deposit_paid', 125000.00, 62500.00, '2027-05-20', 'Deposit paid 3 Jul 2026. Final payment due 3 weeks prior.'),
  ('wedding', 'Band', 'Hot Chocolate', 'booked', 'deposit_paid', 525000.00, 200000.00, '2027-06-03', 'Deposit paid 13 Jul 2026. Final payment due 1 week prior.'),
  ('wedding', 'Florist and Deco', 'Lassana Flora', 'booked', 'deposit_paid', 1878000.00, 470000.00, '2027-05-27', 'Deposit paid 25 Jul 2026. Final payment due 2 weeks prior.'),
  ('wedding', 'Live Wedding Art', 'Aruni', 'booked', 'deposit_paid', 25000.00, 7500.00, '2027-06-10', 'Deposit paid 15 Jul 2026. Final payment due end of event.'),
  ('wedding', 'Wedding Planner', 'Event Celebrations', 'booked', 'deposit_paid', 250000.00, 100000.00, '2027-06-03', 'Deposit paid 29 Jul 2026. Final payment due 1 week prior.'),
  ('wedding', 'Bride Hair and Makeup', 'Ruwani', 'booked', 'deposit_paid', 190000.00, 25000.00, null, 'Deposit paid 17 Jul 2026. Final payment date TBC.');
