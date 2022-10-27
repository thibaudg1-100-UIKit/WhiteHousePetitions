//
//  ViewController.swift
//  Project7
//
//  Created by RqwerKnot on 11/10/2022.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = Array<Petition>()
    var filteredPetitions = [Petition]()
    var filterString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(promptForFilter))
        
        title = "We The People petitions"
        
        // let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        //let urlString = "https://www.hackingwithswift.com/samples/petitions-1.json" // cache from the original content
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        
        showError()
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let decoded = try? decoder.decode(Petitions.self, from: json) {
            petitions = decoded.results
            filteredPetitions = petitions
            tableView.reloadData()
        }
    }
    
    func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func promptForFilter() {
        let ac = UIAlertController(title: "Type in your query", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        let clearFilter = UIAlertAction(title: "Clear", style: .destructive) { [weak self] action in
            self?.filteredPetitions = self?.petitions ?? []
            self?.tableView.reloadData()
            self?.navigationItem.leftBarButtonItem?.tintColor = .none
        }
        
//        let filterAction = UIAlertAction(title: "Filter", style: .default) { [weak ac, weak self] action in
//            if let query = ac?.textFields?[0].text, let results = self?.results(matching: query) {
//                self?.filteredPetitions = results
//                self?.tableView.reloadData()
//                self?.navigationItem.leftBarButtonItem?.tintColor = .red
//            }
//        }
        
        // for GCD challenge:
        let filterAction = UIAlertAction(title: "Filter", style: .default) { [weak ac, weak self] action in
            if let query = ac?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.filter(with: query)
                }
            }
        }
                
        /*
        let filterAction = UIAlertAction(title: "Filter", style: .default) { [weak ac, weak self] action in
            if let query = ac?.textFields?[0].text, let results = self?.results(matching: query) {
                self?.filteredPetitions = results
                self?.tableView.reloadData()
                self?.navigationItem.leftBarButtonItem?.tintColor = .red
            }
        }
         */
        
        ac.addAction(clearFilter)
        ac.addAction(filterAction)
        
        present(ac, animated: true)
    }
    
    func filter(with query: String) {
        let queryLower = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var results = [Petition]()
        
        for petition in petitions {
            if petition.title.lowercased().contains(queryLower) || petition.body.lowercased().contains(queryLower) {
                results.append(petition)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.title = "Filter: \(query)"
            self?.filteredPetitions = results
            self?.tableView.reloadData()
            self?.navigationItem.leftBarButtonItem?.tintColor = .red
        }
    }
    
    func results(matching query: String) -> [Petition] {
        title = "Filter: \(query)"
        
        let queryLower = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        var results = [Petition]()
        
        for petition in petitions {
            if petition.title.lowercased().contains(queryLower) || petition.body.lowercased().contains(queryLower) {
                results.append(petition)
            }
        }
        
        return results
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition = filteredPetitions[indexPath.row]
        
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let petition = filteredPetitions[indexPath.row]
        
        let vc = DetailViewController()
        vc.detailItem = petition
        
        navigationController?.pushViewController(vc, animated: true)
    }

}

