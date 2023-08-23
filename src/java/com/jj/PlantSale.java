/*
 * PlantSale.java
 *
 * Created on March 6, 2006, 8:39 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package com.jj;

import java.util.ArrayList;
import java.util.SortedMap;
import javax.servlet.jsp.jstl.sql.Result;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.csv.CSVRecord;

/**
 *
 * @author Tom  Mueller
 */
public class PlantSale {
    
    public static int divideRoundUp(int a, int b) {
        int c = a / b;
        return c * b < a ? c + 1 : c;
    }
    
    public static String[] getContainedSellerGroups(String groupid, Result sgroups) {
        Integer sgroup = new Integer(groupid);
        SortedMap[] rows = sgroups.getRows();
        int rowcount = sgroups.getRowCount();
        ArrayList sgs = new ArrayList();
        sgs.add(sgroup);
        for (int i = 0; i < sgs.size(); i++) {
            for (int j = 0; j < rowcount; j++) {
                if (rows[j].get("insellergroupID").equals(sgs.get(i))) {
                    Integer newgroup = (Integer)rows[j].get("id");
                    if (!sgs.contains(newgroup)) {
                        sgs.add(newgroup);
                    }
                }
            }
        }
        String sgsstr[] = new String[sgs.size()];
        for (int i = 0; i < sgs.size(); i++) {
            sgsstr[i] = sgs.get(i).toString();
        }
        return sgsstr;
    }
    
    /* 
     * Returns an OrderInfo that contains information about the imported order.
    */
    public static OrderInfo parseCSVOrderData(CSVRecord record, Map<String, OrderProductInfo> saleProducts,
            Map<String, Integer> sellers, Map<String, Integer> customers, Set<String> existingTIDs) {
        OrderInfo order = new OrderInfo();
        order.setId(record.getRecordNumber());
        // Submission Date,Student's Name for Credit,: Products,: Payer Info,: Payer Address,First Name,Last Name,
        // E-mail,Street Address,Street Address Line 2,City,State / Province,Postal / Zip Code,Country,Customer Phone Number (required)

        String dateStr = record.get(0);
        String sellerStr = record.get(1).trim();
        String productsStr = record.get(2);
        String payerInfo = record.get(3);
        String payerAddress = record.get(4); // ignored
        String firstNameStr = record.get(5);
        String lastNameStr = record.get(6);
        String emailStr = record.get(7);
        String addressStr = record.get(8);
        String address2Str = record.get(9); // ignored
        String cityStr = record.get(10);
        String stateStr = record.get(11);
        String zipStr = record.get(12);
        String countryStr = record.get(13); // ignored
        String phoneStr = record.get(14);
        
       
        Date date;
        try {
            date = new SimpleDateFormat("M/d/y H:m").parse(dateStr);
            order.setDate(new SimpleDateFormat("yyyy-MM-dd").format(date));
        } catch (ParseException ex) {
            order.setError("Order has invalid date.");
            Logger.getLogger(PlantSale.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        order.setFirstName(firstNameStr);
        order.setLastName(lastNameStr);
        order.setAddress(addressStr);
        order.setCity(cityStr);
        order.setState(stateStr);
        order.setZip(zipStr);       
        order.setPhone(phoneStr.replaceAll("[^0-9]", ""));
        if (customers.containsKey(order.getPhone())) {
            order.setCustId(customers.get(order.getPhone()).toString());
        }
        order.setEmail(emailStr);
        order.setSellerName(sellerStr);
        
        if (sellers.get(sellerStr) != null) {
            order.setSellerId(sellers.get(sellerStr));
        } else {
            // perform case-insensitive search
            for (String name : sellers.keySet()) {
                if (name.equalsIgnoreCase(sellerStr)) {
                    order.setSellerId(sellers.get(name));
                    break;
                }
            }
            // if still not found, search for single matching case-insensitive substring
            if (order.getSellerId() == null || order.getSellerId() == 0) {
                String foundName = null;
                for (String name : sellers.keySet()) {
                    if (name.toLowerCase().contains(sellerStr.toLowerCase())) {
                        if (foundName == null) {
                            foundName = name;
                        } else {
                            foundName = null;
                            break; // give up searching
                        }
                    }
                }
                if (foundName != null) {
                    order.setSellerId(sellers.get(foundName));
                }
            }
        }
        
        String pi[] = payerInfo.split("Transaction ID: ");
        if (pi.length == 2) {
            order.setTransactionId(pi[1]);
            if (existingTIDs.contains(pi[1])) {
                return null; // this order has aleady been entered
            }
        }
        
        String prods[] = productsStr.split("#");
        if (prods.length > 1) {
            try {
                List<OrderProductInfo> opiList = new ArrayList<>();
                for (int i = 1; i < prods.length; i++) {
                    opiList.add(parseProduct(prods[i], saleProducts));
                }
                order.setProducts(opiList);
            } catch (IllegalArgumentException e) {
                order.setError(e.getMessage());
            }
        }
        String totalStr = productsStr.replaceAll("^.*Total: ", "").replaceAll(" USD.*$", "");
        order.setTotalSale(totalStr);
        
        return order;
    }
    
    // parse: 01 - DONATIONS (Amount: 5.00 USD, Quantity: 5) 
    private static OrderProductInfo parseProduct(String productStr, Map<String, OrderProductInfo> saleProducts) {
        OrderProductInfo opi = new OrderProductInfo();
        
        opi.setNum(productStr.replaceAll(" .*$", ""));
        OrderProductInfo saleProd = saleProducts.get(opi.getNum());
        if (saleProd == null) {
            throw new IllegalArgumentException("Order in previous row refers to a product (" + opi.getNum() + 
                    ") that is not in the current sale.");
        }
        opi.setId(saleProd.getId());
        String quanStr = productStr.replaceAll("^.*Quantity: ", "").replaceAll("\\).*$", "");
        opi.setQuantity(Integer.parseInt(quanStr));
        String amtStr = productStr.replaceAll("^.*Amount: ", "").replaceAll(" USD.*$", "");
        Double price = Double.parseDouble(amtStr);
        int priceInt = (int)(price * 100);
        int prodPriceInt = (int)(saleProd.getAmount() * 100);
        if (priceInt != prodPriceInt) {
            throw new IllegalArgumentException("Order in previous row has a price (" +
                    price + ") for product " + opi.getNum() + " that doesn't match the sale product price (" +
                    saleProd.getAmount() + ").");
        }
        opi.setAmount(price);
        
        return opi;
    }
    
    /** Creates a new instance of PlantSale */
    public PlantSale() {
    }
    
}
