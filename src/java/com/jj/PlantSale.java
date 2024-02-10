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
import jakarta.servlet.jsp.jstl.sql.Result;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.HashSet;
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
    
    public static String getNewUserName(Result users) {
        int rowCount = users.getRowCount();
        if (rowCount == 0) {
            return "user1";
        }
        SortedMap[] rows = users.getRows();
        Set<String> existingUserNames = new HashSet<>();
        for (SortedMap row : rows) {
            existingUserNames.add((String)row.get("username"));
        }
        int uid = 1;
        while (existingUserNames.contains("user" + uid)) {
            uid++;
        }
        return "user" + uid;
    }
    
    public static String[] getContainedSellerGroups(String groupid, Result sgroups) {
        Integer sgroup = Integer.valueOf(groupid);
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
    
    public static boolean contains(List<Integer> list, Integer value) {
        return list.contains(value);
    }
    
    private static final String COLUMN_COUNT_ERROR = "<p>Invalid number of columns (%d) in the input file. The file " +
            "must have the following columns:</p>";
    private static final String COLUMN_MISSING_ERROR = "<p>Column %s is missing. Required columns are:</p>";
    private static final String COLUMN_SPEC = "<ol>" + 
            "<li><b>Submission Date</b> - format: yyyy/mm/dd hh:mm:ss</li>" +
            "<li><b>Student Name for Credit</b> - format: firstname lastname</li>" +
            "<li><b>My Products</b> - value consists of a list of products followed by a Total entry and a" +
            "Transaction ID. Each product " + 
            "starts with a # followed by the product number and a space. The product amount is the number " + 
            "between “Amount: “ and “ USD”. The product quantity is the number between “Quantity: “ and “)”. " + 
            "Other data in the product field such as the name of the product is ignored. The total amount is the " + 
            "number between “Total: $“ and “Transaction” The spaces shown here in quotes are significant. " +
            "The transaction ID is the value between “Transaction ID: ” and “==Payer“. It is possible for this " +
            "field to be split into two fields: <b>My Products: Products</b> and <b>My Products: Payer Info</b>, with the " +
            "transaction ID being in the payer info field.</li>" +
            "<li><b>First Name</b> - customer first name</li>" +
            "<li><b>Last Name</b> - customer last name</li>" +
            "<li><b>E-mail</b> - customer email</li>" +
            "<li><b>Street Address</b> - customer address</li>" +
            "<li><b>City</b> - customer city</li>" +
            "<li><b>State / Province</b> - customer state</li>" +
            "<li><b>Postal / Zip Code</b> - customer zip</li>" +
            "<li><b>Customer Phone Number</b> - format: all non-digits are ignored</li>" +
            "</ol>";
    
    public static ColumnMap parseCSVColumns(CSVRecord record) throws RuntimeException {
        ColumnMap columnMap = new ColumnMap();
        columnMap.setDate(findColumn(record, "Submission Date"));
        columnMap.setSeller(findColumn(record, "Student Name for Credit"));
        try {
            columnMap.setTransaction(findColumn(record, "My Products: Payer Info"));
            columnMap.setProducts(findColumn(record, "My Products: Products"));
        } catch (RuntimeException e) {
            columnMap.setProducts(findColumn(record, "My Products"));
            columnMap.setTransaction(columnMap.getProducts());
        }
        columnMap.setFirstName(findColumn(record, "First Name"));
        columnMap.setLastName(findColumn(record, "Last Name"));
        columnMap.setEmail(findColumn(record, "E-mail"));
        columnMap.setAddress(findColumn(record, "Street Address"));
        columnMap.setCity(findColumn(record, "City"));
        columnMap.setState(findColumn(record, "State"));
        columnMap.setZip(findColumn(record, "Zip Code"));
        columnMap.setPhone(findColumn(record, "Customer Phone Number"));
        return columnMap;
    }
    
    private static int findColumn(CSVRecord record, String name) throws RuntimeException {
        String lowerName = name.toLowerCase();
        for (int i = 0; i < record.size(); i++) {
            if (record.get(i).toLowerCase().contains(lowerName)) {
                return i;
            }
        }
        throw new RuntimeException(String.format(COLUMN_MISSING_ERROR, name) + COLUMN_SPEC);
    }
    
    /* 
     * Returns an OrderInfo that contains information about the imported order.
    */
    public static OrderInfo parseCSVOrderData(ColumnMap columnMap, CSVRecord record, 
            Map<String, OrderProductInfo> saleProducts,
            Map<String, Integer> sellers, Map<String, Integer> customers, Set<String> existingTIDs) {
        
        if (record.size() <= columnMap.getMaxColumn()) {
            throw new RuntimeException(String.format(COLUMN_COUNT_ERROR, record.size()) + COLUMN_SPEC);
        }
        OrderInfo order = new OrderInfo();
        order.setId(record.getRecordNumber());
        // Submission Date,Student's Name for Credit,: Products,: Payer Info,: Payer Address,First Name,Last Name,
        // E-mail,Street Address,Street Address Line 2,City,State / Province,Postal / Zip Code,Country,Customer Phone Number (required)

        String dateStr = record.get(columnMap.getDate());
        String sellerStr = record.get(columnMap.getSeller()).trim();
        String productsStr = record.get(columnMap.getProducts()).replaceAll("[\r\n]", "");
        String transactStr = record.get(columnMap.getTransaction()).replaceAll("[\r\n]", "");
        String firstNameStr = record.get(columnMap.getFirstName());
        String lastNameStr = record.get(columnMap.getLastName());
        String emailStr = record.get(columnMap.getEmail());
        String addressStr = record.get(columnMap.getAddress());
        String cityStr = record.get(columnMap.getCity());
        String stateStr = record.get(columnMap.getState());
        String zipStr = record.get(columnMap.getZip());
        String phoneStr = record.get(columnMap.getPhone());
        
        String dateFormats[] = { "y/M/d H:m:s", "y-M-d H:m:s", "y/M/d", "y-M-d" };
        for (String dateFormat : dateFormats) {
            try {
                Date date = new SimpleDateFormat(dateFormat).parse(dateStr);
                order.setDate(new SimpleDateFormat("yyyy-MM-dd").format(date));
                break;
            } catch (ParseException ex) {
                continue;
            }
        }
        if (order.getDate() == null) {
            order.setError("Order has invalid date.");
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
                    if (name.toLowerCase().contains(sellerStr.toLowerCase()) ||
                        sellerStr.toLowerCase().contains(name.toLowerCase())) {
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
        
        String pi[] = transactStr.split("Transaction ID: ");
        if (pi.length == 2) {
            String tid = pi[1].replaceAll("==Payer.*$", "")
                    .replaceAll(" *Authorization Code.*$", "");
            order.setTransactionId(tid);
            if (existingTIDs.contains(tid)) {
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
        String totalStr = productsStr.replaceAll("^.*Total: \\$*", "")
                .replaceAll("Transaction.*$", "")
                .replaceAll(" USD.*$", "");
        
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
        Double price = Double.valueOf(amtStr);
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
