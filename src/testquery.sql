
select org.id,org.name,org.city,org.contactname,
       count(sale.id)+count(user.id)+count(sellergroup.id)+count(seller.id)+count(customer.id) as count
    from org 
    left join sale on org.id = sale.orgID 
    left join user on org.id = user.orgID
    left join sellergroup on org.id = sellergroup.orgID
    left join seller on org.id = seller.orgID
    left join customer on org.id = customer.orgID
  group by org.id;

 